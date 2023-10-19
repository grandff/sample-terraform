
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}

variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}


# instance 와 alb security group 으로 분리함
variable "instance_security_group_name" {
  description = "The name of the security group for EC2 Instance"
  type        = string
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
}

variable "image_id" {
  description = "The id of the machine image (AMI) to use for the server."
  type        = string
}

variable "instance_type" {
  type = string
}