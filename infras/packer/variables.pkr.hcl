variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet ID where the builder instance will run"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the builder instance (jenkins_agent_sg)"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name for the builder instance"
}