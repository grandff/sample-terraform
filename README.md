# Terraform
terraform 강의 내용 정리 및 예제 내용을 정리한 프로젝트다.

## projects
├── 101 // 단일 서버 배포 기본 예제
│   ├── main.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── 102 // 단일 웹서버 배포 기본 예제
│   ├── digraph.dot
│   ├── digraph.svg
│   ├── main.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── 103 // 웹서버 배포 심화
│   ├── main.tf
│   ├── prod.tfvars
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── userdata.tftpl
├── 104 // auto scaling
│   ├── main.tf
│   ├── mykey
│   ├── mykey.pub
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   ├── tf-key.pem
│   └── userdata.tftpl
├── file-sh-deploy  // file sh 예제
│   ├── main.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── userdata.sh
├── README.md
├── ubuntu-deploy    // ubuntu server 예제
│   ├── main.tf
│   └── terraform.tfstate
├── ubuntu-web-deploy    // ubuntu web server 예제
│   ├── main.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── userdata.tftpl
└── window-deploy   // window server 예제
    ├── main.tf
    ├── terraform.tfstate
    └── terraform.tfstate.backup

## install command
```bash
# .terraform 폴더 구조 확인
sudo yum install tree -y
tree .terraform
```


## References
[command cheat sheet](https://cheat-sheets.nicwortel.nl/terraform-cheat-sheet.pdf)