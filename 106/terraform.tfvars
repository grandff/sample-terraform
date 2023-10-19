server_port                  = 80
instance_security_group_name = "allow_http_ssh_instance"
alb_security_group_name      = "allow_http_alb"
image_id                     = "ami-0f0cc846201190547"
instance_type                = "t3.micro"
alb_name                     = "tfalb-"