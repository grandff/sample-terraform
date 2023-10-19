# security group
resource "aws_security_group" "db" {
  vpc_id      = aws_vpc.main.id # 내가 만든 vpc로 보안그룹설정
  name_prefix = var.db_security_group_name
  description = "Allow MySQL traffic"

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306 # 80
    to_port     = 3306 # 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // anyware
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# db subnet
resource "aws_db_subnet_group" "tf-db" {
    name = "tf-db subnet group"
    subnet_ids = [aws_subnet.pri_a.id, aws_subnet.pri_c.id] # a와 c에 위치할거임
    
    tags = {
        Name = "Terraform DB subnet group"
    }
}

# db instance
resource "aws_db_instance" "tf-db" {
  allocated_storage    = 10
  db_name              = "tf"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "master"
  password             = "tf-password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  
  db_subnet_group_name = aws_db_subnet_group.tf-db.name # subnet 그룹 지정
  vpc_security_group_ids = [aws_security_group.db.id] # security 그룹 지정
  
  multi_az = true   # 서브넷 두군데 모두 생성되게 하는 옵션임 (약간의 시간 소요)
}