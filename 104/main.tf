terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "tf-user"
  region  = "ap-northeast-2" # Asia Pacific (Seoul) region
}

# key pair 추가
resource "aws_key_pair" "mykey" {
  # $ ssh-keygen -m PEM -f mykey -N "" 실행하기
  key_name_prefix = "mykey-" # keyname도 이름중복으로 인한 충돌을 방지하기 위해서 prefix 사용
  public_key = file("mykey.pub")  # public key 조회
}

resource "aws_launch_template" "web" {
  name_prefix            = "lt-web-"         # 이름충돌을 방지하기 위해서 prefix를 사용해서 이름이 안겹치게 함
  image_id               = var.image_id      # "ami-0f0cc846201190547" # Amazon Linux 2 (ap-northeast-2)
  instance_type          = var.instance_type # "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.mykey.key_name

  # user_data는 base64 인코딩
  user_data = base64encode(
    templatefile("userdata.tftpl",{
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


resource "aws_security_group" "web" {
  name        = var.security_group_name # "allow_http"
  description = "Allow HTTP traffic"

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
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "image_id" {
  description = "The id of the machine image (AMI) to use for the server."
  type        = string
}

variable "instance_type" {
  type = string
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

# output "public_ip" {
#   description = "The public IP address of web server"
#   value       = "${aws_instance.web.public_ip}:${var.server_port}"
# }

# output "private_ip" {
#   description = "The private IP address of web server"
#   value       = "${aws_instance.web.private_ip}:${var.server_port}"
# }