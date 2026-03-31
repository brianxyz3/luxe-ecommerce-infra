resource "aws_iam_role" "ecs-exec-role" {
  name = "LuxeAppECSExecRole"

  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "sts:AssumeRole",
          Principal : {
            Service : "ecs-tasks.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "attach-exec-perm" {
  role       = aws_iam_role.ecs-exec-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# VPC Flow Log Role and Policy
data "aws_iam_policy_document" "assume_log_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.project_name}-${var.env}-vpcFlowRole"
  assume_role_policy = data.aws_iam_policy_document.assume_log_role.json
}

data "aws_iam_policy_document" "assume_log_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    effect   = "Allow"
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "flow_logs_policy" {
  role = aws_iam_role.flow_logs_role.id
  policy = data.aws_iam_policy_document.assume_log_policy.json
}


data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_alb_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.infra_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    
    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"
      values = [ data.aws_caller_identity.current.account_id ]
    }
  }
}

data "aws_iam_policy_document" "allow_s3_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.infra_logs.arn}/*"
    ]
    
    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"
      values = [ data.aws_caller_identity.current.account_id ]
    }
  }
}