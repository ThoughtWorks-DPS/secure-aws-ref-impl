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
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy_attachment" "cross_account" {
    provider = "aws.prod"
    name = "cross_account_attachment"
    roles = ["${aws_iam_role.cross_account.name}"]
    policy_arn = "${aws_iam_policy.cross_account_base.arn}"
}
