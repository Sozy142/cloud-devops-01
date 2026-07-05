output "alb_dns_name" {
  value = aws_alb.jenkins_alb.dns_name
}

output "alb_arn_suffix" {
  value = aws_alb.jenkins_alb.arn_suffix
}