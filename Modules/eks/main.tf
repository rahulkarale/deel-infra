//data "aws_subnet" "private" {
//  id = var.private_subnets[var.preferred_az]
//}


resource "aws_placement_group" "default_worker_group" {
  count    = var.enable_placement == "true" ? 1 : 0
  name     = "default_worker_group"
  strategy = "cluster"
  tags = {
    Team       = var.team
    Namespace  = var.namespace
    Stage      = var.stage
    Attributes = var.attributes
    Service    = var.service
    Cluster    = split(".", var.domain_name)[0]
  }
}

locals {
  prefix = "${var.namespace}-${var.stage}"
  name   = var.cluster_name == "" ? split(".", var.domain_name)[0] : var.cluster_name
  userdata = templatefile("userdata.sh", { ssm_cloudwatch_config = "/cloudwatch-agent/config" })
  tags = {
    Team       = var.team
    Namespace  = var.namespace
    Stage      = var.stage
    Attributes = var.attributes
    Service    = var.service
  }
}

module "eks" {
  source                                    = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=tags/v19.16.0"
  cluster_name                              = local.name
  subnet_ids                                = concat(var.private_subnets, var.intra_subnets)
  cluster_version                           = var.cluster_version
  vpc_id                                    = var.vpc_id
  aws_auth_roles                            = var.map_roles
  aws_auth_users                            = var.map_users
  iam_role_path                             = var.iam_path
  enable_irsa                               = true
  create_cluster_security_group             = true
  create_node_security_group                = true
  cluster_enabled_log_types                 = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days    = var.cluster_log_retention_in_days
  node_security_group_id                    = var.node_security_group_id
  cluster_endpoint_private_access           = var.cluster_endpoint_private_access
  cluster_endpoint_public_access            = var.cluster_endpoint_public_access
  eks_managed_node_groups                   = var.eks_managed_node_groups
  node_security_group_additional_rules      = var.node_security_group_additional_rules
  cluster_security_group_additional_rules   = var.cluster_security_group_additional_rules

  # aws-auth configmap
  manage_aws_auth_configmap                 = var.manage_aws_auth_configmap



  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      AmazonEC2RoleforSSM = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
      AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
      NodeClamavPolicy = aws_iam_policy.clamav_policy.arn
      EbsCsiPolicy     = aws_iam_policy.ebs_csi_policy.arn
    }
  }

  cluster_addons = {
    coredns = {
      most_recent   = false
    }
    kube-proxy = {
      most_recent   = false
    }
    aws-efs-csi-driver = {
      most_recent   = false
    }
    aws-ebs-csi-driver = {
      most_recent   = false
    }
    vpc-cni = {
      most_recent              = false
      before_compute           = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  tags = var.stage != "prod" ? local.tags : merge(local.tags, { Tenable = "FA" })
}

data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks.cluster_name]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks.cluster_name]
  name = module.eks.cluster_name
}

resource "aws_iam_policy" "ebs_csi_policy" {
  name   = "${var.namespace}-${local.name}-ebs-csi-policy"
  policy = data.aws_iam_policy_document.ebscsi.json
}

data "aws_iam_policy_document" "ebscsi" {
  statement {
    sid = "EBSCSIAllow"
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DescribeVpcs",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeAvailabilityZones",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "clamav_policy" {
  name   = "${var.namespace}-${local.name}-clamav-s3-policy"
  policy = data.aws_iam_policy_document.clamavReportToS3.json
}

data "aws_iam_policy_document" "denySecurityGroupModification" {
  statement {
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupIngress"
    ]
    effect    = "Deny"
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["aws:eks:cluster-name"]
      variable = "aws:TagKeys"
    }
  }
}

data "aws_iam_policy_document" "clamavReportToS3" {
  statement {
    sid = "S3AccessToAuditBucket"
    actions = [
      "s3:GetBucketAcl",
      "s3:HeadBucket",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutBucketAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:PutObjectTagging",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketLocation"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::jm-audit-clamav-reports",
      "arn:aws:s3:::jm-audit-clamav-reports/*",
      "arn:aws:s3:::jm-audit-aws-logs/*",
      "arn:aws:s3:::jm-audit-aws-logs",
      "arn:aws:s3:::jm-audit-ccsrch-report",
      "arn:aws:s3:::jm-audit-ccsrch-report/*"
    ]
  }

  statement {
    sid = "SSM"
    actions = [
      "ssm:GetParameter"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "KMSAccessToAuditKey"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:kms:ap-south-1:351409330128:key/49fd249e-8b92-411f-9d95-8677b50b0df2",
      "arn:aws:kms:ap-south-1:351409330128:key/d8b006fa-dc9e-4f66-9454-89827b221b9c"
    ]
  }
}


# resource "aws_iam_role_policy" "cluster-DenySecurityGroupModification" {
#   name   = "DenySecurityGroupModification"
#   role   = module.eks.cluster_iam_role_name
#   policy = data.aws_iam_policy_document.denySecurityGroupModification.json
# }


# resource "aws_ssm_parameter" "cw_agent" {
#   count       = var.create_ssm_cw_agent ? 1 : 0
#   description = "Cloudwatch agent config to configure custom log"
#   name        = "/cloudwatch-agent/config"
#   type        = "String"
#   value       = file("cw_agent_config.json")
# }

# resource "aws_autoscaling_notification" "eks_asg_notifications" {
#   count = var.asg_notification_topic_arn != "" ? 1 : 0
#   depends_on = [
#     module.eks
#   ]
#   group_names = module.eks.workers_asg_names

#   notifications = [
#     "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
#   ]

#   topic_arn = var.asg_notification_topic_arn
# }
