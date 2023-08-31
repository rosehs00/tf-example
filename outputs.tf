output "elb_dns_name" {
  value  =  "${aws_elb.simple-elb.dns_name}"
}
