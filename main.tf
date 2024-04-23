#Gary "Trey" Hollander
#Terraform Project

#basic terraform commands to execute
#init
#plan
#apply
#destroy

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }
}

provider "aws" {
    region = "us-east-1"
    #profile = "TerraformBasic1"
}

#Backup instance
provider "aws"{
    alias = "west"
    region = "us-west-1"
}

#VPC = Virtual Private Cloud
#Replace CIDR block here for when IP range for servers is defined
#Thinking 1 IP range for US-East-1 provisioned servers and 1 IP range for West
#Provision third for backup servers
resource "aws_vpc" "example_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Ex-VPC"
    }
}

#Take the info generated from our VPC and hand it to gateway
resource "aws_internet_gateway" "gw"{
    vpc_id = aws_vpc.example_vpc.id
}

#Basic wide open routing table
resource "aws_route_table" "route_table"{
    vpc_id = aws_vpc.example_vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "Ex-RT"
    }
}
resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.example_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Ex-subnet"
    }
}

resource "aws_route_table_association" "route_table_asso" {
    subnet_id = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.route_table.id
}

#Define security group for access and allow access on port 22, 80, 443, & 25565(minecraft testing)
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Minecraft Port"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Web-traffic"
  }
}

#Variable input of user defined server name here handoff when dev
resource "aws_instance"  "example" {
    ami = "ami-011899242bb902164"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_server_sg.name]
    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt-get install apache2 -y
        sudo systemctl start apache2
        sudo apt install wine64 
        echo "New Server - Variable" | sudo tee /var/www/html/index.html
        EOF
    tags = {
        Name = "UbuntuWine"
    }
}

#Build in Logging and setup private access
resource "aws_s3_bucket" "mybucket" {
    bucket = "project1-test-bucket-forgjhollantesting123"
    acl = "private"
    tags = {
        Name = "Persistance-Bucket"
    }
    versioning {
        enabled = true
    }
}


output "public_ip" {
    value = aws_instance.example.public_ip
}