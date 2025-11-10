# main.tf - Secure Terraform Configuration (No Risks)

# Provider configuration
provider "aws" {
  region = "us-east-1"
}



# VPC and Subnet (Private Setup)
resource "aws_vpc" "secure_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.secure_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Security Group (Restrictive)
resource "aws_security_group" "secure_sg" {
  name_prefix = "secure-sg-"
  vpc_id      = aws_vpc.secure_vpc.id

  # Only allow SSH from a specific IP (replace with your IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.1/32"]  # Example: Your office IP
  }

  # No other inbound rules (no public exposure)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (Private, No Public IP)
resource "aws_instance" "secure_instance" {
  ami           = "ami-0c55b159cbfafe1d0"  # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.secure_sg.id]

  # No public IP assigned
  associate_public_ip_address = false

  # Tags for organization
  tags = {
    Name        = "SecureInstance"
    Environment = "Test"
    Sensitive   = "No"  # Not marked as sensitive
  }
}
