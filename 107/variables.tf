variable "image_id" {
  description = "The id of the machine image (AMI) to use for the server."
  type        = string
}

variable "instance_type" {
  type = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}


# instance 와 alb security group 으로 분리함
variable "instance_security_group_name" {
  description = "The name of the security group for EC2 Instance"
  type        = string
}

# db 보안그룹 변수 추가
variable "db_security_group_name" {
  description = "The name of the security group for EC2 Instance"
  type        = string
}