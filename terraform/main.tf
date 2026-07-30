terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    local = {
      source = "hashicorp/local"
    }

    time = {
      source = "hashicorp/time"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "ssh_access" {
  name        = "terraform-multi-container-api"
  description = "Allow SSH access"

  vpc_id = "vpc-01e52f43f82b34fde"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  description = "Todo API"
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "Terraform SSH Security Group"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t2.micro"
  key_name = "DevOpsRoadmap"

  subnet_id = "subnet-063d5b92508c1939c"
  vpc_security_group_ids = [
    aws_security_group.ssh_access.id
  ]
 
  associate_public_ip_address = true

  tags = {
    Name = "Terraform-Instance"
  }
}

resource "time_sleep" "wait_for_ssh" {
  depends_on = [
    aws_instance.web_server
  ]

  create_duration = "30s"
}

resource "local_file" "ansible_inventory" {

  depends_on = [
    aws_instance.web_server
  ]

  filename = "../ansible-server-setup/inventory.ini"

  content = <<EOF
[web]
${aws_instance.web_server.public_ip}

[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/DevOpsRoadmap.pem
EOF
}

resource "null_resource" "run_ansible" {

  triggers = {
    instance_id = aws_instance.web_server.id
  }

  depends_on = [
    time_sleep.wait_for_ssh,
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {

    working_dir = "../ansible-server-setup"

   command = "ansible-playbook -i inventory.ini setup.yml --ssh-common-args='-o StrictHostKeyChecking=no'"
  }
}

output "public_ip" {
  description = "Public IP of the EC2 Instance"

  value = aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 Instance"

  value = aws_instance.web_server.public_dns
}