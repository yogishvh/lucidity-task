variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

variable "aws_instance_type" {
  description = "AWS Instance type"
  default     = "t2.micro"
}

variable "aws_ami_microservice_instance" {
  default = {
    ap-southeast-1 = "aws_ami_microservice_instance"
  }
}

variable "aws_ami_base_lunux" {
  default = {
    ap-southeast-1 = "aws_ami_base_lunux"
  }
}

variable "subnet_id" {
  default = {
    ap-southeast-1 = "subnet_id"
  }
}

variable "env" {
  default = {
    ap-southeast-1 = "prod"
  }
}
