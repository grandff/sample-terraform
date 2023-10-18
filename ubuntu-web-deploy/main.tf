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
resource "aws_instance" "ubuntu" {
  ami                         = var.image_id # Amazon Linux 2 (리전과 동일한 곳에 위치함 이미지를 사용해야함)
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ubuntu.id] # instance에 보안그룹 연결. id를 적어줘야함.
  user_data_replace_on_change = true
  key_name                    = var.ec2_key_name

  # user script 생성
  user_data = templatefile("userdata.tftpl", { 
    port_number = var.server_port
  })
  
  # tag 지정
  tags = {
    Name = "tf-ubuntu-web"
  }
}

# security 그룹 생성
resource "aws_security_group" "ubuntu" {
  name        = var.security_group_name # 변수사용
  description = "Allow HTTP inbound traffic"

  # inbound
  ingress {
    description = "HTTP from VPC"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
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


# 변수 추가
variable "server_port" {
  description = "The port the server will user for HTTP requests"
  type        = number
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}


variable "ssh_port" {
  description = "The port the server will user for SSH"
  type        = number
  default     = 22
}

variable "ec2_key_name" {
  description = "EC2 Key Name"
  type        = string
  default     = "tf-key"
}

# image ami 추가
variable "image_id" {
  description = "Image AMI Name"
  type        = string

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id"
  }
}

# instance type 추가
variable "instance_type" {
  description = "ec2 instance type"
  type        = string
}


# public ip + port 출력
output "public_ip" {
  value       = "${aws_instance.ubuntu.public_ip}:${var.server_port}"
  description = "The public IP address of the web server"
  # 의존성추가
  # aws_instace.web 이 완성되야만 public ip가 출력됨
  depends_on = [
    aws_instance.ubuntu
  ]
}

# private ip 출력
output "private_ip" {
  value       = aws_instance.ubuntu.private_ip
  description = "The private IP address of the web server"
}
