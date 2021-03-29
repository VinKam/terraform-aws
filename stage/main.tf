provider "aws" {
  region  = "us-east-2"
  profile = "backend"
}

locals {
  network_cidr = "10.121.0.0/16"
}


locals {
  security_group_public = {
    ssh = {
      type = "ingress"
      from = 22
      to = 22
      protocol = "tcp"
      cidrs = [var.access_cidrs_in]
    }
    http = {
      type = "ingress"
      from = 80
      to = 80
      protocol = "tcp"
      cidrs = [var.access_cidrs_in]
     }
    }
  }

module "networking" {
  source = "./networking"
  network_cidr_in = local.network_cidr
  public_cidrs = [ for i in range(2, 6, 2): cidrsubnet(local.network_cidr, 8, i) ] 
  private_cidrs = [ for i in range(1, 5, 2): cidrsubnet(local.network_cidr, 8, i)]
  max_subnet = 10
  access_cidrs = var.access_cidrs_in
  security_group_public = local.security_group_public
}

#module "database" {
#  source = "./database"
#  vpc_id = module.networking.network_vpc_id
#  network_cidr = local.network_cidr
#  private_subnet_ids = module.networking.private_subnet_ids
#  db_storage = 5
#  db_engine_version = "5.7.22"
#  db_instance_class = "db.t2.micro"
#  dbname = var.dbname
#  dbuser = var.dbuser
#  dbpassword = var.dbpass
#  db_identifier = "vinkam-rds"
#  skip_db_snapshot  = true
#  db_subnet_group = true
#}

module "loadbalancing" {
  source = "./loadbalancing"
  public_subnets = module.networking.public_subnet_ids
  public_sg = module.networking.public_sg
  network_vpc_id = module.networking.network_vpc_id
  lb_healthy_threshold = 2
  lb_unhealthy_threshold = 2
  lb_timeout = 3
  lb_interval = 30
  tg_port = 80
  tg_protocol = "HTTP"
  listener_port = 80
  listener_protocol = "HTTP"
}


module "compute" {
  source = "./computing"
  instance_count = 1
  instance_type = "t2.micro"
  public_sg = module.networking.public_sg
  public_subnet_ids = module.networking.public_subnet_ids
  instance_vol_size = 10
  instance_key_name = "cloud-network-vk"
  instance_key_path = "/root/.ssh/cloud-network.pub"
  public_target_arn = module.loadbalancing.public_target_arn
}
