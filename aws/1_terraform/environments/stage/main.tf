terraform {
	required_version = ">= 0.12, < 0.13"
}

# Set the variable value in *.tfvars file
# export DIGITALOCEAN_ACCESS_TOKEN=
# Configure the DigitalOcean Provider
provider "digitalocean" {
  version = "~> 1.9"
}

provider "aws" {
	region = "eu-west-1"
  version = "~> 2.0"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = "${data.aws_ami.ubuntu.id}"
	instance_type = "t2.micro"
  key_name = "deployer-key" 
	vpc_security_group_ids = [ "${aws_security_group.web.id}", "${aws_security_group.ssh.id}", "${aws_security_group.out.id}"]
	user_data = <<-EOF
            #!/bin/bash
            sudo apt-get -y update
            sudo apt-get -y upgrade
            sudo apt-get install language-pack-UTF-8
            sudo locale-gen UTF-8
            sudo apt-get -y install htop jq git mc
            EOF
	tags = {
    Name = "terraform-example"
  }
}

resource "aws_key_pair" "dev-key" {
  key_name = "deployer-key" 
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcKTzq6VYYr8sJMXcLXB9RYD7HsGmHLbWZL8axo8Aw9y1FIywSqyIOOAm6nE7dDNGJRlGxjQ/78zH3vjXEecipMjxgWRkmx9jRDbzAC7h1zcTon+7OB2I9oiKiz+CJDWbsr0Ms9F0IVD6oORfG0TUtdT9oBmPCO7sVlmaF7f3oAA+NDb94DuXKeBPGVZ1pBdP+Z4UMNNRl9PuaroyyVtHEEuqB8muDBsC4vryTlCH96K1QKXNwbelascWd1P2VwEs1XmVgAPUmrTzSrXjZO0X0o4j82AmsoC+et6PDnc1kSDc/oy9kY/6z11EOcPg2Fc+kEkzAqlm7yAwjhJaRjc2V dimetron@me.com"
}

#https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html#DefaultSecurityGroup
resource "aws_security_group" "web" {
  	name = "terraform-example-web"

  	ingress {
    	from_port   = 8080
    	to_port     = 8080
    	protocol    = "tcp"
    	cidr_blocks = ["0.0.0.0/0"]
  	}
}

resource "aws_security_group" "ssh" {
    name = "terraform-example-ssh"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "out" {
  name = "terraform-example-out"

  egress {
    to_port           = 0
    from_port         = 0
    protocol          = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new domain using DO API
resource "digitalocean_domain" "default" {
    name = "stage.carmonit.com"
    ip_address = "${aws_instance.example.public_ip}"
}