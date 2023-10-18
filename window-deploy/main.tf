provider "aws" {
    region = "ap-northeast-2" # seoul
    profile = "tf-user" # 해당 profile에서 동작할 수 있게 추가
}

# web server deploy #3 resource add
resource "aws_instance" "windows" {
    ami = "ami-03dc269a0a408d954" # window server
    instance_type = "t3.micro"
    tags  = {
        Name = "tf-windows-web"
    }
}
