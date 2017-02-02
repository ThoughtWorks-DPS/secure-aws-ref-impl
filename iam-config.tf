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

resource "aws_iam_saml_provider" "auth0" {
    name = "auth0"
    saml_metadata_document = "${file("metadata.xml")}"
}

resource "aws_iam_role" "saml_api_role" {
    name = "saml_delegate"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithSAML",
      "Principal": {
        "Federated": "${aws_iam_saml_provider.auth0.arn}"
      },
      "Condition": {
        "StringEquals": {
          "SAML:iss": "urn:manderso.auth0.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "federated_role" {
    name = "federated_role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithSAML",
      "Principal": {
        "Federated": "${aws_iam_saml_provider.auth0.arn}"
      },
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
EOF
}
