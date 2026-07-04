output "nat_sg_id" {
  value = aws_security_group.nat_sg.id
}

output "controller_sg_id" {
  value = aws_security_group.jenkins_controller_sg.id
}

output "agent_sg_id" {
  value = aws_security_group.jenkins_agent_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}