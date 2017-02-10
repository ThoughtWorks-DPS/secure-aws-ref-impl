provider "aws" {
    alias = "preprod"
    region = "us-west-2"
    profile = "secure-aws-preprod"
}

resource "aws_iam_role" "preprod_ops" {
    provider = "aws.preprod"
    name = "Ops"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_role" "preprod_dev_admin" {
    provider = "aws.preprod"
    name = "DevAdmin"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_policy_attachment" "preprod_ops" {
    provider = "aws.preprod"
    name = "preprod_ops_attachment"
    roles = ["${aws_iam_role.preprod_ops.name}"]
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_policy_attachment" "preprod_dev_admin" {
    provider = "aws.preprod"
    name = "preprod_dev_admin_attachment"
    roles = ["${aws_iam_role.preprod_dev_admin.name}"]
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
