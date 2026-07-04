output "controller_instance_id" {
  value = aws_instance.controller_instance.id
}

output "nat_primary_network_interface_id" {
  value = aws_instance.nat_instance.primary_network_interface_id
}

output "nat_instance_public_ip" {
  value = aws_instance.nat_instance.public_ip
}

output "jenkins_ebs_volume_id" {
  value = aws_ebs_volume.jenkins_data.id
}

output "controller_instance_private_ip" {
  value = aws_instance.controller_instance.private_ip
}


output "nat_instance_id" {
  value = aws_instance.nat_instance.id
}