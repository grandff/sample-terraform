# dns name 확인용
output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.alb.dns_name
}


# output "public_ip" {
#   description = "The public IP address of web server"
#   value       = "${aws_instance.web.public_ip}:${var.server_port}"
# }

# output "private_ip" {
#   description = "The private IP address of web server"
#   value       = "${aws_instance.web.private_ip}:${var.server_port}"
# }