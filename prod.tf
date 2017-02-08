provider "aws" {
    alias = "prod"
    region = "us-west-2"
    profile = "secure-aws-account2"
}

resource "aws_iam_policy" "prod_power_user" {
    provider = "aws.prod"
    name = "PowerUser"
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

resource "aws_iam_role" "prod_ops" {
    provider = "aws.prod"
    name = "Ops"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_role" "prod_dev_admin" {
    provider = "aws.prod"
    name = "DevAdmin"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_policy_attachment" "prod_ops" {
    provider = "aws.prod"
    name = "prod_ops_attachment"
    roles = ["${aws_iam_role.prod_ops.name}"]
    policy_arn = "${aws_iam_policy.prod_power_user.arn}"
}

resource "aws_iam_policy_attachment" "prod_dev_admin" {
    provider = "aws.prod"
    name = "prod_dev_admin_attachment"
    roles = ["${aws_iam_role.prod_dev_admin.name}"]
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
