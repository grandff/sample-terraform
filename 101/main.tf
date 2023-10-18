# server deploy #1 provider create
provider "aws" {
    region = "ap-northeast-2" # seoul
    profile = "tf-user" # 해당 profile에서 동작할 수 있게 추가
}

# server deploy #3 resource add
resource "aws_instance" "web" {
    ami = "ami-0f0cc846201190547" # Amazon Linux 2 (리전과 동일한 곳에 위치함 이미지를 사용해야함)
    instance_type = "t2.micro"
    
    tags  = {
        Name = "tf-web"
    }
}
