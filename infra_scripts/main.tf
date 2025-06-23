# This Terraform script sets up an AWS environment with a security group, key pair, and an EC2 instance running a Node.js application.
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC
resource "aws_vpc" "cochlear_vpc" {
  cidr_block         = var.vpc_cidr
  enable_dns_support = true
  tags = {
    Name = "cochlear_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cochlear_igw" {
  vpc_id = aws_vpc.cochlear_vpc.id
  tags = {
    Name = "cochlear_igw"
  }
}

# Route Table
resource "aws_route_table" "cochlear_rt" {
  vpc_id = aws_vpc.cochlear_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cochlear_igw.id
  }
  tags = {
    Name = "cochlear_rt"
  }
}

# Public Subnet 1  (AZ1)
resource "aws_subnet" "cochlear_public_az1" {
  vpc_id                  = aws_vpc.cochlear_vpc.id
  cidr_block              = var.vpc_cidr1
  availability_zone       = var.region2a
  map_public_ip_on_launch = true
  tags                    = { Name = "cochlear_public_az1" }
}

# Public Subnet 2 (AZ2)
resource "aws_subnet" "cochlear_public_az2" {
  vpc_id                  = aws_vpc.cochlear_vpc.id
  cidr_block              = var.vpc_cidr2
  availability_zone       = var.region2b
  map_public_ip_on_launch = true
  tags                    = { Name = "cochlear_public_az2" }
}

# Associate subnets to the route table
resource "aws_route_table_association" "cochlear_az1_assoc" {
  subnet_id      = aws_subnet.cochlear_public_az1.id
  route_table_id = aws_route_table.cochlear_rt.id
}

resource "aws_route_table_association" "cochlear_az2_assoc" {
  subnet_id      = aws_subnet.cochlear_public_az2.id
  route_table_id = aws_route_table.cochlear_rt.id
}

# Security Group for EC2
resource "aws_security_group" "cochlear_app_sg" {
  name   = "cochlear_app_sg"
  vpc_id = aws_vpc.cochlear_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = { Name = "cochlear_app_sg" }
}

# Security Group for Load Balancer
resource "aws_security_group" "cochlear_lb_sg" {
  name        = "cochlear_lb_sg"
  vpc_id      = aws_vpc.cochlear_vpc.id
  description = "Security group for Cochlear Node.js load balancer"

  ingress {
    description = "Allow HTTP"
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
    Name = "cochlear_lb_sg"
  }
}

# This resource creates an EC2 instance in the first availability zone
resource "aws_instance" "node_server_az1" {
  ami                         = "ami-010876b9ddd38475e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.cochlear_public_az1.id
  associate_public_ip_address = true
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.cochlear_app_sg.id]


  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nodejs npm git
              git clone https://github.com/${var.github_username}/cochlear_node_task.git /home/ubuntu/cochlear_node_task
              cd /home/ubuntu/cochlear_node_task
              npm install
              npm run build
              node dist/index.js &
              EOF
  tags = {
    Name = "cochlear_node_server_az1"
  }
}

# This resource creates an EC2 instance in the second availability zone
resource "aws_instance" "node_server_az2" {
  ami                         = "ami-010876b9ddd38475e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.cochlear_public_az2.id
  associate_public_ip_address = true
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.cochlear_app_sg.id]


  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nodejs npm git
              git clone https://github.com/${var.github_username}/cochlear_node_task.git /home/ubuntu/cochlear_node_task
              cd /home/ubuntu/cochlear_node_task
              npm install
              npm run build
              node dist/index.js &
              EOF
  tags = {
    Name = "cochlear_node_server_az2"
  }
}

# Target Group
resource "aws_lb_target_group" "cochlear_tg" {
  name        = "cochlear-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cochlear_vpc.id
  target_type = "instance"

  health_check {
    path                = "/hello"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "cochlear_tg"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "cochlear_az1_attachment" {
  target_group_arn = aws_lb_target_group.cochlear_tg.arn
  target_id        = aws_instance.node_server_az1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "cochlear_az2_attachment" {
  target_group_arn = aws_lb_target_group.cochlear_tg.arn
  target_id        = aws_instance.node_server_az2.id
  port             = 80
}


# Application Load Balancer (ALB) for the Node.js application
resource "aws_lb" "cochlear_alb" {
  name               = "cochlear-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cochlear_lb_sg.id]
  subnets            = [aws_subnet.cochlear_public_az1.id, aws_subnet.cochlear_public_az2.id]

  tags = {
    Name = "cochlear_alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "cochlear_listener" {
  load_balancer_arn = aws_lb.cochlear_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cochlear_tg.arn
  }
}

# Output the DNS name of the ALB
output "alb_dns_name" {
  value = aws_lb.cochlear_alb.dns_name
}
