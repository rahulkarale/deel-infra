module "iam_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = ""

  tags = {
    Namespace  = var.namespace
    Stage      = var.stage
    Team       = var.team
    Service    = var.service
    Attributes = var.attributes
  }
}

locals {
    metrics_server = {
        role_name = join("-", [module.iam_label.id, "metrics-server"])
    } 

    external_secrets = {
        role_name = join("-", [module.iam_label.id, "external-secrets"])
    } 

    aws_load_balancer_controller = {
        role_name = join("-", [module.iam_label.id, "alb-controller"])
    } 

    external_dns = {
        role_name = join("-", [module.iam_label.id, "external-dns"])
        values = [
            <<-EOT
                interval: "10s"
                sources:
                    - service
                    - istio-gateway
                    - ingress
                txtOwnerId: "alb"
                txtPrefix: "_"
                rbac:
                    create: true
                env: 
                    - name: AWS_DEFAULT_REGION
                      value: ap-south-1
                policy: sync
                # metrics:
                #     enabled: true
                #     serviceMonitor:
                #     enabled: true
                #     interval: "10s"
                #     namespace: monitoring
                #     selector:
                #         prometheus: kube
                resources:
                    limits:
                    cpu: 100
                    memory: 150Mi
                    requests:
                    memory: 100Mi
                    cpu: 50m
            EOT
        ]

    } 

    cluster_autoscaler = {
        role_name = join("-", [module.iam_label.id, "cluster-autoscaler"])
        values = [
            <<-EOT
                extraArgs:
                    balance-similar-node-groups: true
                    scale-down-enabled: true
                    scale-down-delay-after-add: 5m
                    scale-down-delay-after-delete: 5m
                    expander: least-waste
                    scale-down-utilization-threshold: 0.85
                    skip-nodes-with-local-storage: false
                    skip-nodes-with-system-pods: false
                    ignore-daemonsets-utilization: true
                    logtostderr: true
                    stderrthreshold: info
                    v: 4
                # serviceMonitor:
                #     enabled: true
                #     interval: "10s"
                #     namespace: monitoring
                #     selector:
                #     prometheus: kube
            EOT
        ]
        # https://docs.aws.amazon.com/eks/latest/userguide/pod-security-policy-removal-faq.html
        # set = [
        #     {
        #         name = "rbac.pspEnabled"
        #         value = true
        #     }
        # ]
    }
}


module "metrics_server_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"
    version = "~> 1.5"

    cluster_name                            = var.cluster_name
    cluster_endpoint                        = var.cluster_endpoint
    cluster_version                         = var.cluster_version
    oidc_provider_arn                       = var.oidc_provider_arn

    # Metrics Servers
    enable_metrics_server                   = var.enable_metrics_server
    metrics_server                          = merge(local.metrics_server, var.metrics_server)   

    tags = merge(module.iam_label.tags, {
        Name = local.metrics_server.role_name
    })
}

module "external_secrets_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"
    version = "~> 1.5"

    cluster_name                            = var.cluster_name
    cluster_endpoint                        = var.cluster_endpoint
    cluster_version                         = var.cluster_version
    oidc_provider_arn                       = var.oidc_provider_arn

    # External Secrets
    enable_external_secrets                 = var.enable_external_secrets
    external_secrets                        = merge(local.external_secrets, var.external_secrets)
    external_secrets_ssm_parameter_arns     = var.external_secrets_ssm_parameter_arns
    external_secrets_secrets_manager_arns   = var.external_secrets_secrets_manager_arns
    external_secrets_kms_key_arns           = var.external_secrets_kms_key_arns 

    tags = merge(module.iam_label.tags, {
        Name = local.external_secrets.role_name
    })
}

module "aws_load_balancer_controller_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"
    version = "~> 1.5"

    cluster_name                            = var.cluster_name
    cluster_endpoint                        = var.cluster_endpoint
    cluster_version                         = var.cluster_version
    oidc_provider_arn                       = var.oidc_provider_arn

    # AWS Load Balancer Controller
    enable_aws_load_balancer_controller     = var.enable_aws_load_balancer_controller
    aws_load_balancer_controller            = merge(local.aws_load_balancer_controller, var.aws_load_balancer_controller)

    tags = merge(module.iam_label.tags, {
        Name = local.aws_load_balancer_controller.role_name
    })

}

module "cluster_autoscaler_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"
    version = "~> 1.5"

    cluster_name                            = var.cluster_name
    cluster_endpoint                        = var.cluster_endpoint
    cluster_version                         = var.cluster_version
    oidc_provider_arn                       = var.oidc_provider_arn

    # Cluster AutoScaler
    enable_cluster_autoscaler               = var.enable_cluster_autoscaler
    cluster_autoscaler                      = merge(var.cluster_autoscaler, local.cluster_autoscaler)

    tags = merge(module.iam_label.tags, {
        Name = local.cluster_autoscaler.role_name
    })
}

module "external_dns_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"
    version = "~> 1.5"

    cluster_name                            = var.cluster_name
    cluster_endpoint                        = var.cluster_endpoint
    cluster_version                         = var.cluster_version
    oidc_provider_arn                       = var.oidc_provider_arn

    # External DNS
    enable_external_dns                     = var.enable_external_dns
    external_dns                            = merge(local.external_dns, var.external_dns)
    external_dns_route53_zone_arns          = var.external_dns_route53_zone_arns

    tags = merge(module.iam_label.tags, {
        Name = local.external_dns.role_name
    })
}