provider "aws" {
    region = "us-west-2"
    profile = "secure-aws-admin"
}

resource "aws_iam_account_password_policy" "password_policy" {
    allow_users_to_change_password = true
    max_password_age = 180
    minimum_password_length = 9
    password_reuse_prevention = 3
}

