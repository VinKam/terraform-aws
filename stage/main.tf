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
