output "nat_instance_profile_name" {
  value = aws_iam_instance_profile.nat_instance_profile.name
}

output "controller_instance_profile_name" {
  value = aws_iam_instance_profile.jenkins_controller_profile.name
}

output "agent_instance_profile_name" {
  value = aws_iam_instance_profile.jenkins_agent_profile.name
}