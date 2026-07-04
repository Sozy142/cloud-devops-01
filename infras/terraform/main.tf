module "vpc" {
  source                 = "./modules/vpc"
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidr     = var.public_subnet_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  private_subnet_cidr    = var.private_subnet_cidr
  aws_region             = var.aws_region
  project_name           = local.project_name
  common_tags            = local.common_tags
}

module "security" {
  source              = "./modules/security"
  vpc_id              = module.vpc.vpc_id
  private_subnet_cidr = module.vpc.private_subnet_cidr
  project_name        = local.project_name
  common_tags         = local.common_tags
}

module "iam" {
  source       = "./modules/iam"
  project_name = local.project_name
  common_tags  = local.common_tags
}

module "compute" {
  source                      = "./modules/compute"
  ami_id                      = data.aws_ami.amazon_linux_2023.id
  nat_instance_type           = var.nat_instance_type
  controller_instance_type    = var.controller_instance_type
  public_subnet_id            = module.vpc.public_subnet_id
  private_subnet_id           = module.vpc.private_subnet_id
  nat_sg_id                   = module.security.nat_sg_id
  controller_sg_id            = module.security.controller_sg_id
  nat_instance_profile        = module.iam.nat_instance_profile_name
  controller_instance_profile = module.iam.controller_instance_profile_name
  key_name                    = var.key_name
  jenkins_snapshot_id         = var.jenkins_snapshot_id
  project_name                = local.project_name
  common_tags                 = local.common_tags
}

module "alb" {
  source                 = "./modules/alb"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet_id
  public_subnet_az2_id   = module.vpc.public_subnet_az2_id
  alb_sg_id              = module.security.alb_sg_id
  controller_instance_id = module.compute.controller_instance_id
  project_name           = local.project_name
  common_tags            = local.common_tags
}

# Private NAT route — nằm ở root vì bridge giữa vpc và compute module
resource "aws_route" "private_nat_route" {
  route_table_id         = module.vpc.private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.compute.nat_primary_network_interface_id
}