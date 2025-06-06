terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.regiao_aws
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "machine" {
  image_id           = data.aws_ami.ubuntu.id
  instance_type = var.instancia
  key_name = var.chave
  tags = {
    Name = "IaC Curso 3"
  }
  security_group_names = [ var.grupoDeSeguranca ]

  user_data = var.producao ? filebase64("ansible.sh") : ""
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub") 
}

resource "aws_autoscaling_group" "grupo" {
  availability_zones = [ "${var.regiao_aws}a", "${var.regiao_aws}b" ]
  name = var.groupName
  max_size = var.max_machine
  min_size = var.min_machine
  launch_template {
    id = aws_launch_template.machine.id
    version = "$Latest"
  }
   target_group_arns = var.producao ? [ aws_lb_target_group.alvoLoadBalancer[0].arn ] : []
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets = [ aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id ]
  security_groups = [ aws_security_group.acesso_geral.id ]
   count = var.producao ? 1 : 0
}

resource "aws_default_vpc" "vpc"{

}

resource "aws_lb_target_group" "alvoLoadBalancer"{
  name = "maquinasAlvo"
  port = "8000"
  protocol = "HTTP"
  vpc_id = aws_default_vpc.vpc.id
   count = var.producao ? 1 : 0
}

resource "aws_lb_listener" "entradaLoadbalancer" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer[0].arn
  }
   count = var.producao ? 1 : 0
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name = "terraform-escala"
  autoscaling_group_name = var.groupName
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  count = var.producao ? 1 : 0
}


