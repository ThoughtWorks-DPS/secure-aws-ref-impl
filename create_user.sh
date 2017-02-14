#!/bin/bash
USER_NAME=$1
GROUP_NAME=$2

set -e

aws iam create-user \
    --user-name $USER_NAME \
    --profile secure-aws-admin

aws iam add-user-to-group \
    --user-name $USER_NAME \
    --group-name $GROUP_NAME \
    --profile secure-aws-admin

ACCESS_KEY_JSON=$(aws iam create-access-key \
    --user-name $USER_NAME \
    --profile secure-aws-admin \
    | jq ".AccessKey")

touch .credentials-$USER_NAME
echo -e "export AWS_ACCESS_KEY_ID=$(echo $ACCESS_KEY_JSON | jq -r ".AccessKeyId")"\
    "\nexport_AWS_SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_SON | jq -r ".SecretAccessKey")"\
    > .credentials-$USER_NAME

MFA_SERIAL=$(aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name $USER_NAME \
    --outfile /tmp/${USER_NAME}_MFA.png \
    --bootstrap-method QRCodePNG \
    --profile secure-aws-admin \
    | jq -r ".VirtualMFADevice.SerialNumber")

set +e


[[ "$OSTYPE" == "darwin"* ]] && open /tmp/${USER_NAME}_MFA.png || xdg-open /tmp/${USER_NAME}_MFA.png

echo "after you scan this QR code (/tmp/${USER_NAME}_MFA.png), record two consecutive auth codes and run the following command"
echo "aws iam enable-mfa-device --user-name $USER_NAME --serial-number $MFA_SERIAL" \
    "--profile secure-aws-admin --authentication-code-1 <first-code> --authentication-code-2 <second-code>"

