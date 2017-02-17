#!/bin/bash
# Handy script for assuming roles. you need to set some variables,
# and then pass in a valid OTP token when you call it.
#   usage: . assume_role.sh <account_number> <role> <otp-token>
#       N.B. the `. ` is important to source the variables into the calling
#       shell.
#   Variables to set:
#       ACCOUNT: the account number for the user you have credentials for
#       MFA_DEVICE_NAME: the name you provided for the MFA device
#
#   This tries to not be overly clever, and does not assume that your user necessarily
#   has the permissions necessary to retrieve your MFA serial number at run time.
#   It does expect to use either the default credentials or credentials set as environment
#   variables.
set -e

ACCOUNT=
MFA_DEVICE_NAME=
ACCOUNT_TO_ACCESS=$1
ROLE_TO_ASSUME=$2
OTP_TOKEN=$3

CREDENTIALS_JSON=$(aws sts assume-role \
    --role-arn arn:aws:iam::${ACCOUNT_TO_ACCESS}:role/$ROLE_TO_ASSUME \
    --role-session-name foo \
    --serial-number arn:aws:iam::${ACCOUNT}:mfa/$MFA_DEVICE_NAME \
    --token-code $OTP_TOKEN \
    | jq ".Credentials")
cat <<EOF >.credentials-$ACCOUNT_TO_ACCESS-$ROLE_TO_ASSUME
export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS_JSON | jq -r ".AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS_JSON | jq -r ".SecretAccessKey")
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS_JSON | jq -r ".SessionToken")
EOF
echo "source .credentials-$ACCOUNT_TO_ACCESS-$ROLE_TO_ASSUME to assume role"
