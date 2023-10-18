# web server deploy #1 provider create
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
  region  = "ap-northeast-2" # seoul
  profile = "tf-user"        # 해당 profile에서 동작할 수 있게 추가
}

# web server deploy #3 resource add
resource "aws_instance" "web" {
  ami                    = "ami-0f0cc846201190547" # Amazon Linux 2 (리전과 동일한 곳에 위치함 이미지를 사용해야함)
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id] # instance에 보안그룹 연결. id를 적어줘야함.
  user_data_replace_on_change = true  # user data 변경 옵션

  # user script 생성
  user_data = file("${path.module}/userdata.sh")

  # tag 지정
  tags = {
    Name = "tf-web"
  }
}

# security 그룹 생성
resource "aws_security_group" "web" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  # inbound
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}