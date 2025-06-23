variable "region" {
  default = "ap-southeast-2"
}

variable "region2a" {
  default = "ap-southeast-2a"
}

variable "region2b" {
  default = "ap-southeast-2b"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_cidr1" {
  default = "10.0.1.0/24"
}

variable "vpc_cidr2" {
  default = "10.0.2.0/24"
}
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "github_username" {
  description = "The GitHub username to clone repositories"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "The AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "your_ip" {
  description = "The IP address to allow SSH access"
  type        = string
  sensitive   = true
}

variable "aws_key_name" {
  description = "The AWS Key Name"
  type        = string
  sensitive   = true
}
