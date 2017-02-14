#!/bin/bash
# Handy script for assuming roles. you need to set some variables,
# and then pass in a valid TOTP token when you call it.
#   usage: . assume_role.sh <totp-token>
#       N.B. the `. ` is important to source the variables into the calling
#       shell.
#   Variables to set:
#       PROFILE: the profile from ~/.aws/credentials to be used
#       ACCOUNT: the account number for the user you have credentials for
#       MFA_DEVICE_NAME: the name you provided for the MFA device
#       ACOUNT_TO_ASSUME: account number where you're trying to assume a role
#       ROLE_TO_ASSUME: the name (not arn) of the role you are assuming
#
#   This tries to not be overly clever, and does not assume that your user necessarily
#   has the permissions necessary to retrieve your MFA serial number at run time.
PROFILE=
ACCOUNT=
MFA_DEVICE_NAME=
ACCOUNT_TO_ACCESS=
ROLE_TO_ASSUME=

CREDENTIALS_JSON=$(aws sts assume-role \
    --role-arn arn:aws:iam::$ACCOUNT_TO_ACCESS:role/$ROLE_TO_ASSUME \
    --role-session-name foo \
    --serial-number arn:aws:iam::$ACCOUNT:mfa/$MFA_DEVICE_NAME \
    --token-code $1 \
    --profile $PROFILE \
    | jq ".Credentials")

export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS_JSON | jq -r ".AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS_JSON | jq -r ".SecretAccessKey")
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS_JSON | jq -r ".SessionToken")
