# key pair 추가
resource "aws_key_pair" "mykey" {
  # $ ssh-keygen -m PEM -f mykey -N "" 실행하기
  key_name_prefix = "mykey-"          # keyname도 이름중복으로 인한 충돌을 방지하기 위해서 prefix 사용
  public_key      = file("mykey.pub") # public key 조회
}

# security group
resource "aws_security_group" "web" {
  vpc_id      = aws_vpc.main.id                  # 내가 만든 vpc로 보안그룹설정
  name_prefix = var.instance_security_group_name # "allow_http"
  description = "Allow HTTP And SSH traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = var.server_port # 80
    to_port     = var.server_port # 80
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

resource "aws_instance" "web" {
  ami                         = var.image_id      # "ami-0f0cc846201190547" # Amazon Linux 2 (ap-northeast-2)
  instance_type               = var.instance_type # "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web.id]
  user_data_replace_on_change = true
  key_name                    = aws_key_pair.mykey.key_name
  subnet_id                   = aws_subnet.pub_c.id # 어느 서브넷에 만들지 지정해줘야함 안그러면 또 default에다가 만듬

  user_data = templatefile("userdata.tftpl", {
    port_number = var.server_port
  })

  tags = {
    Name = "tf-web-pub-apne-2c"
  }
}