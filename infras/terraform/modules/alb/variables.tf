variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "public_subnet_az2_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "controller_instance_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}