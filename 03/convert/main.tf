terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# =========================================================
# Variables
# =========================================================

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access"
  type        = string
}

# =========================================================
# Data Source
# =========================================================

# CloudFormation의 LatestAmiId와 동일한 역할
data "aws_ssm_parameter" "latest_amazon_linux_2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My-VPC"
  }
}

# =========================================================
# Internet Gateway
# =========================================================

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-IGW"
  }
}

# =========================================================
# Public Route Table
# =========================================================

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-Public-RT"
  }
}

resource "aws_route" "my_default_public_route" {
  route_table_id         = aws_route_table.my_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id

  depends_on = [
    aws_internet_gateway.my_igw
  ]
}

# =========================================================
# Public Subnet 1
# =========================================================

resource "aws_subnet" "my_public_sn1" {
  vpc_id = aws_vpc.my_vpc.id

  cidr_block = "10.0.0.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "My-Public-SN-1"
  }
}

# =========================================================
# Public Subnet 2
# =========================================================

resource "aws_subnet" "my_public_sn2" {
  vpc_id = aws_vpc.my_vpc.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "My-Public-SN-2"
  }
}

# =========================================================
# Route Table Association
# =========================================================

resource "aws_route_table_association" "my_public_sn1_association" {
  subnet_id      = aws_subnet.my_public_sn1.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "my_public_sn2_association" {
  subnet_id      = aws_subnet.my_public_sn2.id
  route_table_id = aws_route_table.my_public_rt.id
}

# =========================================================
# Security Group
# =========================================================

resource "aws_security_group" "web_sg" {
  name        = "WEBSG"
  description = "Enable HTTP access via port 80 and SSH access via port 22"

  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "WEBSG"
  }

  # HTTP
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =========================================================
# EC2 - 1
# =========================================================

resource "aws_instance" "my_ec2_1" {
  ami           = data.aws_ssm_parameter.latest_amazon_linux_2_ami.value
  instance_type = "t2.micro"

  key_name = var.key_name

  subnet_id = aws_subnet.my_public_sn1.id

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash

    hostname EC2-1

    yum install httpd -y

    systemctl start httpd
    systemctl enable httpd

    echo "<h1>CloudNet@ EC2-1 Web Server</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "EC2-1"
  }
}

# =========================================================
# EC2 - 2
# =========================================================

resource "aws_instance" "my_ec2_2" {
  ami           = data.aws_ssm_parameter.latest_amazon_linux_2_ami.value
  instance_type = "t2.micro"

  key_name = var.key_name

  subnet_id = aws_subnet.my_public_sn2.id

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash

    hostname EC2-2

    yum install httpd -y

    systemctl start httpd
    systemctl enable httpd

    echo "<h1>CloudNet@ EC2-2 Web Server</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "EC2-2"
  }
}

# =========================================================
# Elastic IP - EC2-1
# =========================================================

resource "aws_eip" "my_eip_1" {
  domain = "vpc"

  tags = {
    Name = "My-EIP-1"
  }
}

resource "aws_eip_association" "my_eip_1_assoc" {
  instance_id   = aws_instance.my_ec2_1.id
  allocation_id = aws_eip.my_eip_1.id
}

# =========================================================
# Elastic IP - EC2-2
# =========================================================

resource "aws_eip" "my_eip_2" {
  domain = "vpc"

  tags = {
    Name = "My-EIP-2"
  }
}

resource "aws_eip_association" "my_eip_2_assoc" {
  instance_id   = aws_instance.my_ec2_2.id
  allocation_id = aws_eip.my_eip_2.id
}

# =========================================================
# ALB Target Group
# =========================================================

resource "aws_lb_target_group" "alb_target_group" {
  name     = "My-ALB-TG"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.my_vpc.id

  target_type = "instance"

  health_check {
    protocol = "HTTP"
    port     = "80"
    path     = "/"
  }
}

# =========================================================
# Target Group Attachment - EC2-1
# =========================================================

resource "aws_lb_target_group_attachment" "ec2_1_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn

  target_id = aws_instance.my_ec2_1.id

  port = 80
}

# =========================================================
# Target Group Attachment - EC2-2
# =========================================================

resource "aws_lb_target_group_attachment" "ec2_2_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn

  target_id = aws_instance.my_ec2_2.id

  port = 80
}

# =========================================================
# Application Load Balancer
# =========================================================

resource "aws_lb" "application_load_balancer" {
  name = "My-ALB"

  load_balancer_type = "application"

  internal = false

  security_groups = [
    aws_security_group.web_sg.id
  ]

  subnets = [
    aws_subnet.my_public_sn1.id,
    aws_subnet.my_public_sn2.id
  ]

  tags = {
    Name = "My-ALB"
  }
}

# =========================================================
# ALB Listener
# =========================================================

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# =========================================================
# Outputs
# =========================================================

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "ec2_1_public_ip" {
  value = aws_eip.my_eip_1.public_ip
}

output "ec2_2_public_ip" {
  value = aws_eip.my_eip_2.public_ip
}

output "alb_dns_name" {
  value = aws_lb.application_load_balancer.dns_name
}
