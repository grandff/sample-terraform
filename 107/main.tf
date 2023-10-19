# vpc create
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-vpc"
  }
}

# internetgateway create
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id # vpc에 연결

  tags = {
    Name = "tf-igw"
  }
}

# public subnets cteate
resource "aws_subnet" "pub_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # 퍼블릭 ip 요청 여부

  tags = {
    Name = "tf-subnet-public1-ap-northeast-2a"
  }
}

resource "aws_subnet" "pub_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet-public2-ap-northeast-2c"
  }
}

# route table
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-rtb-public"
  }
}

# route table association
resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.pub.id
}
resource "aws_route_table_association" "pub_c" {
  subnet_id      = aws_subnet.pub_c.id
  route_table_id = aws_route_table.pub.id
}

# 고정ip생성. nat gateway는 퍼블릭에 만듭니다! 다시한번더 기억합시다!
resource "aws_eip" "pub_a" {
  domain = "vpc"
  tags = {
    Name = "tf-eip-ap-northeast-2a"
  }
}

# nat gateway 생성
resource "aws_nat_gateway" "gw_a" {
  allocation_id = aws_eip.pub_a.id # subnet a 에 생성
  subnet_id     = aws_subnet.pub_a.id

  tags = {
    Name = "tf-nat-pub1-apne-2a"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # 
  depends_on = [aws_internet_gateway.gw]
}

# pivate subnets cteate
resource "aws_subnet" "pri_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "tf-subnet-private1-ap-northeast-2a"
  }
}

resource "aws_subnet" "pri_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "tf-subnet-private2-ap-northeast-2c"
  }
}



# route table
resource "aws_route_table" "pri_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id # private 은 nat gateway를 연결하므로 반드시 natgateway를 적어야함!
  }

  tags = {
    Name = "tf-rtb-private1"
  }
}
resource "aws_route_table" "pri_c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id # private 은 nat gateway를 연결하므로 반드시 natgateway를 적어야함!
  }

  tags = {
    Name = "tf-rtb-private2"
  }
}



resource "aws_route_table_association" "pri_a" {
  subnet_id      = aws_subnet.pri_a.id
  route_table_id = aws_route_table.pri_a.id
}
resource "aws_route_table_association" "pri_c" {
  subnet_id      = aws_subnet.pri_c.id
  route_table_id = aws_route_table.pri_c.id
}