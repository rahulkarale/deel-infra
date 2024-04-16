variable "aws_assume_role_arn" {
  type    = string
  default = ""
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}

variable "team" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}


variable "domain_name" {
  type        = string
  description = "DNS zone name"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "private_subnets" {
  type = list(string)
}

variable "intra_subnets" {
  type    = list(string)
  default = []
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "manage_aws_auth_configmap" {
  description = "Determines whether to manage the aws-auth configmap"
  type        = bool
  default     = true
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "enable_placement" {
  default = "true"
}

variable "worker_additional_policies" {
  default = []
  type    = list(string)
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  default     = "/"
}

variable "worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults for valid keys."
  type        = any
  default     = []
}

variable "eks_managed_node_groups" {
  description = "Map of map of node groups to create. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}

variable "config_out_path" {
  type    = string
  default = "/usr/local/share/kube"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "eks_pods_secruity_group" {
  description = "To Attach common pods security group to connect to EKS api server."
  type        = string
  default     = ""
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_name" {
  default = ""
}

variable "audit_eks_secruity_group" {
  type        = string
  description = "Audit Cluster Secruity group"
  default     = ""
}

variable "vpn_whitelisted_cidr" {
  type        = list(any)
  description = "VPN whitelisted cidr to Access EKS Cluster endpoint"
  default     = []
}

variable "service" {
  type        = string
  default     = ""
  description = "Github repo for required resource, empty value will make it gitops repo"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "The key pair name that should be used for the instances in the autoscaling group"
}

variable "root_volume_size" {
  default     = "20"
  type        = number
  description = "Root volume size for node workers"
}

variable "root_volume_type" {
  default     = "gp3"
  type        = string
  description = "Volume Type to be used"
}

variable "attributes" {
  type        = string
  default     = "unknown"
  description = "Custom attributes signifying purpose of resource"
}

variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "cluster_log_retention_in_days" {
  default     = 30
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
}

variable "node_security_group_id" {
  default = ""
}

variable "asg_notification_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN for autoscaling activity notification"
}

// tempararly added untill prod eks cluster updated from 1.19 to 1.20
variable "worker_ami_name_filter_windows" {
  description = "Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used."
  type        = string
  default     = "Windows_Server-2019-English-Core-EKS_Optimized-*"
}

variable "create_ssm_cw_agent" {
  type    = bool
  default = true
}
