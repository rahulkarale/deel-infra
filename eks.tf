module "eks_cluster" {
  source = "../../../Modules/eks"
  service                         = path_relative_to_include()
  cluster_name                    = "deel-cluster"
  attributes                      = "deel"
  team                            = "devops"
  namespace                       = "infrastructure"
  vpc_id                          = module.vpc.vpc_id
  private_subnets                 = module.vpc.private_subnets
  enable_placement                = false
  cluster_version                 = "1.28"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

#  map_roles = [
#    {
#      rolearn  = "arn:aws:iam::${get_aws_account_id()}:role/admin"
#      username = "prod-admin"
#      groups   = ["system:masters"]
#    },
#    {
#      rolearn  = "arn:aws:iam::${get_aws_account_id()}:role/sysadmin"
#      username = "prod-sysadmin"
#      groups   = ["system:masters"]
#    }
#  ]

#  map_users = [
#    {
#      userarn  = "arn:aws:iam::66666666666:user/user1"
#      username = "user1"
#      groups   = ["system:masters"]
#    },
#    {
#      userarn  = "arn:aws:iam::66666666666:user/user2"
#      username = "user2"
#      groups   = ["system:masters"]
#    },
#  ]

  eks_managed_node_groups = {
    deel-private = {
      min_size                    = 2
      max_size                    = 10
      desired_size                = 2
      instance_types              = ["m6a.xlarge"]
      capacity_type               = "ON_DEMAND"
    }
  }
  domain_name = "example.deel.dev.com"
  stage       = "dev"
}