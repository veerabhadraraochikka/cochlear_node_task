variable "region" {
  default = "ap-southeast-2"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
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
