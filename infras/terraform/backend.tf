terraform {
    backend "s3" {
        bucket = "jenkins-aws-terraform-state-592245848352"
        key    = "jenkins-aws/terraform.tfstate"
        region = "ap-southeast-1"
        dynamodb_table = "jenkins-aws-terraform-lock"
        encrypt = true
    }
}