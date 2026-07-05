
variable "controller_instance_id" {
  type        = string
  description = "Jenkins Controller instance ID"
}

variable "nat_instance_id" {
  type        = string
  description = "NAT instance ID"
}

variable "alb_arn_suffix" {
  type        = string
  description = "ALB ARN suffix for CloudWatch metrics"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN for alarm notifications"
}

variable "project_name" {
  type        = string
}

variable "common_tags" {
  type        = map(string)
}