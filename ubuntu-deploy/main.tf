provider "aws" {
    region = "ap-northeast-2" # seoul
    profile = "tf-user" # 해당 profile에서 동작할 수 있게 추가
}

# web server deploy #3 resource add
resource "aws_instance" "ubuntu" {
    ami = "ami-04341a215040f91bb" # ubuntu20
    instance_type = "t2.micro"
    tags  = {
        Name = "tf-ubuntu-web"
    }
}
