packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "jenkins_agent" {
  ami_name      = "jenkins-aws-agent-ami-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "al2023-ami-202*-kernel-6.*-x86_64"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = false

  communicator  = "ssh"
  ssh_username  = "ec2-user"
  ssh_interface = "session_manager"

  tags = {
    Name      = "jenkins-aws-agent-ami"
    Project   = "jenkins-aws"
    ManagedBy = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.jenkins_agent"]

  provisioner "shell" {
    inline = [
      "sudo dnf install -y java-21-amazon-corretto",
      "sudo dnf install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo dnf install -y git",
      "sudo usermod -aG docker ec2-user"
    ]
  }
}