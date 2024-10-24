provider "aws" {
  region     = "us-east-1"
  access_key =
  secret_key =
}

module "ebs_volume" {
  source            = "./modules/ebs"
  volume_size       = 20
  availability_zone = "us-east-1a"
}

module "security_group" {
  source = "./modules/security"
}

module "public_ip" {
  source        = "./modules/ip"
  instance_id   = aws_instance.adem.id
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "key-exam-adem"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "adem" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name

  tags = {
    Name = "instance-adem-examen"
  }

  vpc_security_group_ids = [
    module.security_group.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ip_ec2.txt"
  }
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.adem.id
  allocation_id = module.public_ip.eip_id
}
