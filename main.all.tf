provider "aws" {
  region = "ap-northeast-2"
}

#resource "aws_instance" "simple" {
#  ami = "ami-04341a215040f91bb"
#  instance_type = "t3.micro"
#  vpc_security_group_ids = ["${aws_security_group.instance.id}"] 
#  user_data = <<-EOF
#	#!/bin/bash
#	echo "Hello, Terraform!!" > index.html
#	nohup busybox httpd -f -p 8080 &
#	EOF
#
#  tags = {
#   Name = "simple-server"
#  }
#}
#resource "aws_security_group" "instance" {
#  name =  "simple-web-sg"
#  ingress {
#      from_port = 8080
#      to_port = 8080
#      protocol = "tcp"
#      cidr_blocks = ["0.0.0.0/0"]
#    }
#}

resource "aws_launch_configuration" "simple" {
    image_id  		             = "ami-04341a215040f91bb"
    instance_type                 = "t3.micro"
    security_groups = ["${aws_security_group.instance.id}"]
user_data = <<-EOF
	#!/bin/bash
	echo "Hello, Terraform!!" > index.html
	nohup busybox httpd -f -p "${var.web_port}"&
	EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name =  "simple-web-sg"
  ingress {
      from_port = "${var.web_port}"
      to_port = "${var.web_port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "simple-asg" {

launch_configuration      = "${aws_launch_configuration.simple.id}"
availability_zones           = "${data.aws_availability_zones.all.names}"

load_balancers	= [ "${aws_elb.simple-elb.name}"]
health_check_type	= "ELB"

	min_size                         = 2
        max_size                        = 5
tag {
    key                            = "Name"
   value                          = "asg-web-servers"
   propagate_at_launch = true
}
}
data "aws_availability_zones" "all" {}
resource "aws_elb" "simple-elb" {
name  		             = "tf-elb"
availability_zones           = "${data.aws_availability_zones.all.names}"
security_groups		= ["${aws_security_group.elb-sg.id}"]

           listener {
             lb_port	= 80
    	lb_protocol	= "http"
   	instance_port	= "${var.web_port}"
	instance_protocol 	= "http"
          }
         health_check {
            healthy_threshold	= 2
	unhealthy_threshold	= 2
	timeout		= 3
	interval			= 30
	target			= "HTTP:${var.web_port}/"
	}
}

resource "aws_security_group" "elb-sg" {
           name  		= "tf-elb-sg"

        ingress {
             from_port	= 80
	to_port		= 80
    	protocol		= "tcp"
   	cidr_blocks 	= ["0.0.0.0/0"]
	}
	egress {
             from_port	=  0
	to_port		=  0
    	protocol	= "-1"
   	cidr_blocks 	= ["0.0.0.0/0"]
	}
}
