terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"  # Use the latest AWS provider
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

# Fetch the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id  # Uses the latest Ubuntu 22.04 AMI
  instance_type = "t3.micro"              # Free-tier eligible (change if needed)
  key_name      = "iac-guilherme"    

  tags = {
    Name = "IaC Instance - 2"
  }

  # Ensure the instance is updated on launch
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              EOF
}