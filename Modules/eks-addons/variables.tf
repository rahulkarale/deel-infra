variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the cluster OIDC Provider"
  type        = string
}

variable "namespace" {
  type = string
}

variable "name" {
  type = string
}

variable "stage" {
  type = string
}

variable "service" {
  type = string
}

variable "attributes" {
  type = string
}

variable "team" {
  type = string
}

################################################################################
# Metrics Server
################################################################################

variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

variable "metrics_server" {
  description = "Metrics Server add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# External Secrets
################################################################################

variable "enable_external_secrets" {
  description = "Enable External Secrets operator add-on"
  type        = bool
  default     = false
}

variable "external_secrets" {
  description = "External Secrets add-on configuration values"
  type        = any
  default     = {}
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:kms:*:*:key/*"]
}

################################################################################
# AWS Load Balancer Controller
################################################################################

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# Cluster Autoscaler
################################################################################

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

variable "cluster_autoscaler" {
  description = "Cluster Autoscaler add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# External DNS
################################################################################

variable "enable_external_dns" {
  description = "Enable external-dns operator add-on"
  type        = bool
  default     = false
}

variable "external_dns" {
  description = "external-dns add-on configuration values"
  type        = any
  default     = {}
}

variable "external_dns_route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records (if using Route53)"
  type        = list(string)
  default     = []
}

################################################################################
# Cloudwatch.tf
################################################################################
variable "create_cloudwatch" {
  default = false
  type    = bool
}

variable "cloudwatch_additional_trusted_service_account" {
  default = []
  type    = list(string)
}

variable "cloudwatch_audit_grafana_assume_role" {
  default = []
  type    = list(string)
}

variable "trusted_assume_service" {
  default = []
  type    = list(string)
}

variable "oidc_audience_arn" {
  type        = string
  description = "eks oidc provider role arn"
  default     = ""
}

variable "oidc_subject" {
  type        = string
  description = "eks oidc subject arn"
  default     = ""
}

variable "eks_node_role" {
  default = ""
  type    = string
}
