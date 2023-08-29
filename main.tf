provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "simple" {
  ami = "ami-04341a215040f91bb"
  instance_type = "t3.micro"
  tags = {
   Name = "simple-server"
  }
}
