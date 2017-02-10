provider "aws" {
    alias = "infra"
    region = "us-west-2"
    profile = "secure-aws-infra"
}

resource "aws_iam_role" "infra_ops" {
    provider = "aws.infra"
    name = "Ops"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_role" "infra_dev_admin" {
    provider = "aws.infra"
    name = "DevAdmin"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
resource "aws_iam_policy_attachment" "infra_ops" {
    provider = "aws.infra"
    name = "infra_ops_attachment"
    roles = ["${aws_iam_role.infra_ops.name}"]
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_policy_attachment" "infra_dev_admin" {
    provider = "aws.infra"
    name = "infra_dev_admin_attachment"
    roles = ["${aws_iam_role.infra_dev_admin.name}"]
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
