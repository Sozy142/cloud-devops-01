variable "ami_id" {
  type = string
}

variable "nat_instance_type" {
  type = string
}

variable "controller_instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "nat_sg_id" {
  type = string
}

variable "controller_sg_id" {
  type = string
}

variable "nat_instance_profile" {
  type = string
}

variable "controller_instance_profile" {
  type = string
}

variable "key_name" {
  type = string
}

variable "jenkins_snapshot_id" {
  type    = string
  default = null
}

variable "project_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}