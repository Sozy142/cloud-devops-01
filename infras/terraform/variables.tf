variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy the Jenkins infrastructure"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The CIDR block for the public subnet"
}

variable "public_subnet_az2_cidr" {
  type        = string
  description = "The CIDR block for the public subnet az2"
}

variable "private_subnet_cidr" {
  type        = string
  description = "the CIDR for the private subnet"
}

variable "controller_instance_type" {
  type        = string
  description = "EC2 instance size for controller"
}

variable "nat_instance_type" {
  type        = string
  description = "EC2 instance size for NAT"
}

variable "agent_instance_type" {
  type        = string
  description = "EC2 instance size agent" 
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access to NAT instance"
  type        = string
}

variable "jenkins_snapshot_id" {
  type        = string
  description = "EBS snapshot ID to restore Jenkins data from. Leave null for fresh install."
  default     = null
}