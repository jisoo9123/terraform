output "ec2_cennection" {
  value = "ssh ec2-user@${aws_instance.myEC2.public_ip}"
  }
