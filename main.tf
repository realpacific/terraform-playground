terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform"
  }
}

resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf-vpc.id

}

resource "aws_route_table" "tf-route-table" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  } 

}

resource "aws_route_table_association" "table-a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.tf-route-table.id
}

resource "aws_security_group" "allow_web" {
  name   = "allow_web"
  vpc_id = aws_vpc.tf-vpc.id

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

resource "aws_eip" "elastic_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.tf-igw]
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.tf-vpc.id
  availability_zone = "ap-south-1b"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "subnet-1"
  }
}




resource "aws_instance" "app_server" {
  ami           = "ami-0ad704c126371a549"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1b"
  key_name      = "ec2-key"
  tags = {
    Name = "terraform"  
     
  }

  network_interface  {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
    #! /bin/sh
    sudo su
    yum update -y
    yum install httpd -y
    systemctl start httpd
    echo "<h1>HELLO TERRAFORM</h1>" >> /var/www/html/index.html
    EOF
}