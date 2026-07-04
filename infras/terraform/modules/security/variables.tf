variable "vpc_id" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "project_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}