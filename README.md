# Secure AWS Configuration Reference implementation

working off of [this article](https://thoughtworks.jiveon.com/people/mheiber/blog/2016/06/23/using-aws-with-security-as-a-first-class-citizen)
by Moritz. Will add more to the README later.

This aims to illustrate setting up a nice secure AWS configuration, with separate accounts for IAM and resource manipulation and all that good stuff.
Some parts can't be automated, so in the README we'll explain those bits.

For the purposes of this example we use 4 separate AWS accounts, one each for IAM, infrastructure, preprod, and prod.

## Manual Steps
1. [Create an admin user](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) for each account.
This is important because you don't want to be using the root user to change these accounts.
2. Put AWS admin user access keys for each account in ~/.aws/credentials. These should be added under the profiles `secure-aws-admin`, `secure-aws-prod`,
`secure-aws-preprod`, and `secure-aws-infra`, corresponding to the purpose of each of the accounts. **A WORD OF WARNING:** Once you have established your account setup
and have created personal users (or, ideally once SSO is set up), you will want to disable these bootstrap accounts for safety. For the time being, 
we will need them to do some set up for testing below.

(See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles for an example.  Replace user2 with secure-aws-admin.) When you're done, your aws files will look like this:

.aws/config

    [profile secure-aws-prod]
    region = us-west-2

    [profile secure-aws-preprod]
    region = us-west-2

    [profile secure-aws-admin]
    region = us-west-2

    [profile secure-aws-infra]
    region = us-west-2

.aws/credentials

    [secure-aws-prod]
    aws_access_key_id = AKIA1...
    aws_secret_access_key = mfhgjr8485r...

    [secure-aws-preprod]
    aws_access_key_id = AKIA2...
    aws_secret_access_key = fjfjasljdfl...

    [secure-aws-admin]
    aws_access_key_id = AKIA3...
    aws_secret_access_key = 4easdfabca...

    [secure-aws-infra]
    aws_access_key_id = AKIA4...
    aws_secret_access_key = jfjmcmas...

## Creating and testing an Operators user
Now that you have your account set up, you will need to add some users to test that everything is working correctly. 
Add an ops users with the following commands:

        # Creates the user
        ➜ aws iam create-user --user-name ops --profile secure-aws-admin
       
       {
            "User": {
                "UserName": "ops",
                "Path": "/",
                "CreateDate": "2017-02-14T16:55:37.228Z",
                "UserId": "AIDA32D....",
                "Arn": "arn:aws:iam::123123123123:user/ops"
            }
        }

        # Adds them to the group
        ➜ aws iam add-user-to-group --user-name ops --group-name Operators --profile secure-aws-admin

        # Creates their credentials
        ➜ aws iam create-access-key --user-name ops --profile secure-aws-admin
        
        {
            "AccessKey": {
                "UserName": "ops",
                "Status": "Active",
                "CreateDate": "2017-02-14T16:57:39.444Z",
                "SecretAccessKey": "FLK32D...",
                "AccessKeyId": "AKIA436U..."
            }
        }

Create a script called .credentials-ops for later use based on the above output: 

    export AWS_ACCESS_KEY_ID=AKIA43IU...
    export AWS_SECRET_ACCESS_KEY=FLKJKJD...

You can source this at any point to become your ops user, so it should be readable only by you. Now you need to enable MFA.

        #Creates an MFA device, this adds a file called mfa.png which you need to
        #scan with your MFA application
        ➜ aws iam create-virtual-mfa-device --virtual-mfa-device-name OpsTestMFA --outfile ./mfa.png \
            --bootstrap-method QRCodePNG --profile secure-aws-admin

        {
            "VirtualMFADevice": {
                "SerialNumber": "arn:aws:iam::412412412412:mfa/OpsTestMFA"
            }
        }

At this point, you need to scan the QR code in mfa.png with your MFA application (e.g. google authenticator).

        #Enable the MFA device with a sequence of two auth codes from the application
        ➜ aws iam enable-mfa-device --user-name ops --serial-number arn:aws:iam::412412412412:mfa/OpsTestMFA \
            --authentication-code-1 444703 --authentication-code-2 438360 --profile secure-aws-admin

The ops users should now be ready to go. You can test that they have permissions with the following commands:

        ➜ bash -c '. ./.credentials-ops; aws sts assume-role --role-arn arn:aws:iam::123123123123:role/Ops \
            --role-session-name ops-test --serial-number arn:aws:iam::412412412412:mfa/OpsTestMFA --token-code 034267'

        {
            "AssumedRoleUser": {
                "AssumedRoleId": "AROAIRX...:ops-test",
                "Arn": "arn:aws:sts::123123123123:assumed-role/Ops/ops-test"
            },
            "Credentials": {
                "SecretAccessKey": "CNn4k...",
                "SessionToken": "FQoDYXdz...",
                "Expiration": "2017-02-14T20:28:04Z",
                "AccessKeyId": "ASIAI..."
            }
        }

        ➜ AWS_SESSION_TOKEN=FQoDYXdz... AWS_SECRET_ACCESS_KEY=CNn4k... AWS_ACCESS_KEY_ID=ASIAI... aws s3 mb s3://test-bucket-1123123123
        
        make_bucket: test-bucket-1123123123

Because the user has permission to assume role, and the role has permission to view hosts, it allows create the bucket

A note on the complexity of the above: you would certainly want to wrap this basic functionality up in scripts for onboarding and role assumption;
an example of such a script is provided in this repo. For more information on MFA with the CLI, see the
[AWS instructions](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/).

## Creating and testing a DevAdmins user
Add a dev users with the following commands:

       ➜ aws iam create-user --user-name dev --profile secure-aws-admin
       
       {
            "User": {
                "UserName": "dev",
                "Path": "/",
                "CreateDate": "2017-02-14T16:55:37.228Z",
                "UserId": "AIDA5AD....",
                "Arn": "arn:aws:iam::123123123123:user/dev"
            }
        }

        ➜ aws iam add-user-to-group --user-name dev --group-name DevAdmins --profile secure-aws-admin

        ➜ aws iam create-access-key --user-name dev --profile secure-aws-admin
        
        {
            "AccessKey": {
                "UserName": "dev",
                "Status": "Active",
                "CreateDate": "2017-02-14T16:57:39.444Z",
                "SecretAccessKey": "FLKJKJD...",
                "AccessKeyId": "AKIA43IU..."
            }
        }

As before, create a script that only you can read called .credentials-dev for later use based on the above output: 

    export AWS_ACCESS_KEY_ID=AKIA43IU...
    export AWS_SECRET_ACCESS_KEY=FLKJKJD...

Enable MFA for this user.

    ➜ aws iam create-virtual-mfa-device --virtual-mfa-device-name DevTestMFA --outfile ./mfa.png \
        --bootstrap-method QRCodePNG --profile secure-aws-admin

    {
        "VirtualMFADevice": {
            "SerialNumber": "arn:aws:iam::412412412412:mfa/DevTestMFA"
        }
    }

    ➜ aws iam enable-mfa-device --user-name dev --serial-number arn:aws:iam::412412412412:mfa/DevTestMFA \
        --authentication-code-1 614180 --authentication-code-2 724697 --profile secure-aws-admin

Now test:
    ➜ bash -c '. ./.credentials-dev; aws sts assume-role --role-arn arn:aws:iam::123123123123:role/DevAdmin \
        --role-session-name dev-test --serial-number arn:aws:iam::412412412412:mfa/DevTestMFA --token-code 465005'

        {
            "AssumedRoleUser": {
                "AssumedRoleId": "AROA...:dev-test",
                "Arn": "arn:aws:sts::123123123123:assumed-role/DevAdmin/dev-test"
            },
            "Credentials": {
                "SecretAccessKey": "Tu5GTG...",
                "SessionToken": "FQoDYXd...",
                "Expiration": "2017-02-14T21:03:07Z",
                "AccessKeyId": "ASIAIU..."
            }
        }

        ➜ AWS_SESSION_TOKEN=FQoDYXd... AWS_SECRET_ACCESS_KEY=Tu5GTG... AWS_ACCESS_ID=ASIAI... aws s3 mb s3://test-bucket
        
        make_bucket failed: s3://test-bucket An error occurred (AccessDenied) when calling the CreateBucket operation: Access Denied

The call to make the bucket fails because the user doesn't have permission, as expected.

If you would like to assume a role with any of the accounts using the console, you will need to be logged in as one of the defined users and then visit 
https://signin.aws.amazon.com/switchrole?account=[accountId]&roleName=[RoleForThatUser]. 
For this to work, you need to create [login profiles](http://docs.aws.amazon.com/cli/latest/reference/iam/create-login-profile.html) 
for the user.
