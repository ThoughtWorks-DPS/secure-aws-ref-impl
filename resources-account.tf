provider "aws" {
    alias = "prod"
    region = "us-west-2"
    profile = "secure-aws-account2"
}

resource "aws_iam_policy" "cross_account_base" {
    provider = "aws.prod"
    name = "CrossAccountBasePolicy"
    path = "/"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "NotAction": ["iam:*", "organizations:*"],
      "Resource": "*"
    },{
      "Effect": "Allow",
      "Action": "organizations:DescribeOrganization",
      "Resource": "*"
    }
    ]
}
EOF
}

resource "aws_iam_role" "cross_account" {
    provider = "aws.prod"
    name = "CrossAccountSignin"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cross_account" {
    provider = "aws.prod"
    name = "cross_account_attachment"
    roles = ["${aws_iam_role.cross_account.name}"]
    policy_arn = "${aws_iam_policy.cross_account_base.arn}"
}
