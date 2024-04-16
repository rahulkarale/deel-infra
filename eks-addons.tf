module "eks-addons" {
  source = "../../../Modules/eks-addons"
  cluster_name                       = module.eks_cluster.cluster_name
  cluster_endpoint                   = module.eks_cluster.cluster_endpoint
  cluster_version                    = module.eks_cluster.cluster_version
  oidc_provider_arn                  = module.eks_cluster.oidc_provider_arn
  cluster_certificate_authority_data = module.eks_cluster.cluster_certificate_authority_data

  # Tags
  service    = "eks-addons"
  attributes = "infra"
  team       = "lending"
  name       = "base"
  namespace  = "infrastructure"

  enable_metrics_server = true
  metrics_server = {
    values = [
      <<-EOT
        podDisruptionBudget:
          maxUnavailable: 1
        metrics:
          enabled: true
      EOT
    ]
    set = [
      {
        name  = "replicas"
        value = 2
      }
    ]
  }

  enable_external_secrets = true

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      }
    ]
  }

  enable_cluster_autoscaler = true
  cluster_autoscaler = {
    set = [

    ]
  }

  enable_external_dns = true
  external_dns_route53_zone_arns = ["example.deel.dev.com"]
  external_dns = {
    set = [

    ]
  }
  create_cloudwatch = true
  eks_node_role     = module.eks_cluster.cluster_iam_role_arn

  oidc_audience_arn       = module.eks_cluster.oidc_provider_arn
  oidc_subject            = module.eks_cluster.cluster_oidc_issuer_url
  stage = "dev"
}