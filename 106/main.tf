
# key pair 추가
resource "aws_key_pair" "mykey" {
  # $ ssh-keygen -m PEM -f mykey -N "" 실행하기
  key_name_prefix = "mykey-"          # keyname도 이름중복으로 인한 충돌을 방지하기 위해서 prefix 사용
  public_key      = file("mykey.pub") # public key 조회
}

resource "aws_launch_template" "web" {
  name_prefix            = "lt-web-"         # 이름충돌을 방지하기 위해서 prefix를 사용해서 이름이 안겹치게 함
  image_id               = var.image_id      # "ami-0f0cc846201190547" # Amazon Linux 2 (ap-northeast-2)
  instance_type          = var.instance_type # "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.mykey.key_name # 위에서 생성한 key_pair를 등록해서 사용

  # user_data는 base64 인코딩
  user_data = base64encode(
    templatefile("userdata.tftpl", {
      port_number = var.server_port
    })
  )

  tags = {
    Name = "tf-web"
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix = "asg-web-" # 이름충돌을 방지하기 위해서 prefix를 사용해서 이름이 안겹치게 함
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.default.ids

  # 대상 그룹에 포함시켜야하므로 반드시 해야함!!
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"


  min_size = 4
  max_size = 8

  tag {
    key                 = "Name"
    value               = "tf-asg-web"
    propagate_at_launch = true
  }

  # lifecycle 
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      # launch_template이 변경됐을 때
      aws_launch_template.web.latest_version
    ]
  }
}

# alb listener rule 추가
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"] # 모든 요청에 대해서 실행
    }
  }

  action {
    type             = "forward"                   # 모든 요청에 대해서 forward 시킴 어디로?
    target_group_arn = aws_lb_target_group.asg.arn # target group 으로 설정한 곳으로..
  }
}

resource "aws_security_group" "web" {
  name_prefix = var.instance_security_group_name # "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80 # var.server_port
    to_port     = 80 # var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# alb 보안 그룹 추가
resource "aws_security_group" "alb" {
  name_prefix = var.alb_security_group_name
  description = "Allow HTTP traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = var.server_port # 80
    to_port     = var.server_port # 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# alb 추가
resource "aws_lb" "alb" {
  name_prefix        = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id] # 여러개를 쓸 수 있어서 []로 설정..
}

# alb listener 추가
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found\n"
      status_code  = 404
    }
  }
}

# 대상그룹 생성
resource "aws_lb_target_group" "asg" {
  name_prefix = var.alb_name # prefix 가 가능한건 되도록 prefix 쓰기.. 이름 겹치기 오류 방지
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2 # 두번 실패하면 unhealthy로 판단
  }
}



# 데이터 추가
data "aws_vpc" "default" {
  default = true # default 가 true인 vpc 정보 조회 (vpc 속성에 보면 확인할 수 있음)
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
