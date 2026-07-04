output "alb_dns_name" {
  description = "ALB DNS name — use this to configure GitHub webhook URL"
  value       = module.alb.alb_dns_name
}

output "controller_instance_id" {
  description = "Jenkins Controller instance ID — use this to start SSM session"
  value       = module.compute.controller_instance_id
}

output "controller_instance_private_ip" {
  description = "Jenkins Controller Instance private IP"
  value       = module.compute.controller_instance_private_ip
}

output "nat_instance_public_ip" {
  description = "NAT instance public IP"
  value       = module.compute.nat_instance_public_ip
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "agent_sg_id" {
  value = module.security.agent_sg_id
}

output "agent_iam_profile_name" {
  value = module.iam.agent_instance_profile_name
}

output "jenkins_ebs_volume_id" {
  description = "Jenkins EBS volume ID — use this to create snapshot before destroy"
  value       = module.compute.jenkins_ebs_volume_id
}

output "nat_instance_id" {
  description = "NAT instance ID"
  value       = module.compute.nat_instance_id
}