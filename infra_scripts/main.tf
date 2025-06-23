# This Terraform script sets up an AWS environment with a security group, key pair, and an EC2 instance running a Node.js application.
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "cochlear_web_sg" {
  name = "cochlear_web_sg"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.your_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This resource creates an EC2 instance with Node.js and the hello-server application
resource "aws_instance" "node_server" {
  ami           = "ami-010876b9ddd38475e"
  instance_type = "t2.micro"
  key_name      = var.aws_key_name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nodejs npm git
              git clone https://github.com/veerabhadraraochikka/cochlear_node_task.git home/ubuntu/cochlear_node_task
              cd home/ubuntu/cochlear_node_task
              npm install
              npm run build
              node dist/index.js &
              EOF

  tags = {
    Name = "CochlearNodeServer"
  }
}
