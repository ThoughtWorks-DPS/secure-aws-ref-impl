provider "aws" {
    alias = "admin"
    region = "us-west-2"
    profile = "secure-aws-admin"
}
data "aws_caller_identity" "current" {
    provider = "aws.admin"
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = [ "sts:AssumeRole" ]
        principals {
            type = "AWS"
            identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
        condition {
            test = "Bool"
            variable = "aws:MultiFactorAuthPresent"
            values = ["true"]
        }
    }
}
output "iam_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

resource "aws_iam_account_password_policy" "password_policy" {
    provider = "aws.admin"
    allow_users_to_change_password = true
    max_password_age = 180
    minimum_password_length = 9
    password_reuse_prevention = 3
}

resource "aws_iam_group" "dev_admins" {
    provider = "aws.admin"
    name = "DevAdmins"
}
resource "aws_iam_group" "operators" {
    provider = "aws.admin"
    name = "Operators"
}

# These policies are the only parts of this file that need to be updated for additional environments
resource "aws_iam_group_policy" "dev_admins" {
    provider = "aws.admin"
    name = "DevAdmins"
    group = "${aws_iam_group.dev_admins.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
            "${aws_iam_role.prod_dev_admin.arn}",
            "${aws_iam_role.preprod_dev_admin.arn}",
            "${aws_iam_role.infra_dev_admin.arn}"
        ]
    }
}
EOF
}

resource "aws_iam_group_policy" "operators" {
    provider = "aws.admin"
    name = "OperatorsPolicy"
    group = "${aws_iam_group.operators.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
            "${aws_iam_role.prod_ops.arn}",
            "${aws_iam_role.preprod_ops.arn}",
            "${aws_iam_role.infra_ops.arn}"
        ]
    }
}
EOF
}

resource "aws_iam_user" "dev" {
    provider = "aws.admin"
    name = "Dev"
}

resource "aws_iam_group_membership" "dev_admins" {
    provider = "aws.admin"
    name = "dev_admins_membership"
    users = ["${aws_iam_user.dev.name}"]
    group = "${aws_iam_group.dev_admins.name}"
}

resource "aws_iam_user" "ops" {
    provider = "aws.admin"
    name = "Ops"
}

resource "aws_iam_group_membership" "ops" {
    provider = "aws.admin"
    name = "ops_membership"
    users = ["${aws_iam_user.ops.name}"]
    group = "${aws_iam_group.operators.name}"
}
