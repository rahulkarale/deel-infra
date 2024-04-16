data "aws_caller_identity" "current" {}
resource "aws_iam_role" "cloudwatch_default" {
  count                = var.create_cloudwatch ? 1 : 0
  name                 = "${module.iam_label.id}-cloudwatch"
  description          = "Role that can be assumed by metric-exporter or cloudwatch scheduler"
  max_session_duration = "43200"
  assume_role_policy   = data.aws_iam_policy_document.cloudwatch_trust[0].json
  tags = merge(module.iam_label.tags, {
    Name = "${module.iam_label.id}-cloudwatch"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_default" {
  count      = var.create_cloudwatch ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_default[0].name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_readonly" {
  count      = var.create_cloudwatch ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.cloudwatch_default[0].name
}


data "aws_iam_policy_document" "cloudwatch_trust" {
  count = var.create_cloudwatch ? 1 : 0
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        var.oidc_audience_arn]
    }
    condition {
      test     = "StringEquals"
      values   = concat(["system:serviceaccount:kube-system:cni-metrics", "system:serviceaccount:monitoring:cloudwatch-agent"], var.cloudwatch_additional_trusted_service_account)
      variable = "${var.oidc_subject}:sub"
    }
  }

  statement {
    effect = "Allow"
    principals {
      identifiers = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_node_role}"])
      type        = "AWS"
    }
    actions = [
      "sts:AssumeRole",
    ]
  }

  statement {
    effect = "Allow"
    principals {
      identifiers = length(var.trusted_assume_service) > 0 ? var.trusted_assume_service : ["apigateway.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole",
    ]
  }
}


data "aws_iam_policy_document" "clouwatch_assume_role_default" {
  count = var.stage == "audit" ? 1 : 0
  statement {
    sid = "GrafanaAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    effect    = "Allow"
    resources = var.cloudwatch_audit_grafana_assume_role
  }

}

resource "aws_iam_policy" "clouwatch_assume_role_default" {
  count  = var.stage == "audit" ? 1 : 0
  name   = "${var.stage}-assume-role"
  policy = data.aws_iam_policy_document.clouwatch_assume_role_default[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_assume_role_default" {
  count      = var.stage == "audit" ? 1 : 0
  policy_arn = aws_iam_policy.clouwatch_assume_role_default[0].arn
  role       = aws_iam_role.cloudwatch_default[0].name
}
