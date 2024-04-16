module "vpc" {
  source = "../../../Modules/vpc"
  name = "deel-dev-vpc"
  cidr = "120.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b"]
  private_subnets  = ["120.0.0.0/20", "120.0.16.0/20"]
  database_subnets = ["120.0.128.0/24", "120.0.129.0/24"]
  public_subnets   = ["120.0.254.0/24", "120.0.255.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
}