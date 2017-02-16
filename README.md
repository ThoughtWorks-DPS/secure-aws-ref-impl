# Secure AWS Configuration Reference implementation

working off of [this article](https://www.thoughtworks.com/insights/blog/using-aws-security-first-class-citizen)
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
You can manually create users, but we have provided a simple shell script to wrap the various calls needed for this.
To begin creating a user in the Operators group, simply call:

       ➜ ./create_user.sh ops Operators
       {
                "User": {
                        "UserName": "ops",
                        "Path": "/",
                        "CreateDate": "2017-02-16T01:21:21.998Z",
                        "UserId": "AIDA....",
                        "Arn": "arn:aws:iam::123123123:user/ops"
                }
        }

        after you scan this QR code (/tmp/ops.png), record two consecutive auth codes and run the following command
        aws iam enable-mfa-device --user-name ops --serial-number arn:aws:iam::123123123:mfa/ops --profile secure-aws-admin --authentication-code-1 <first-code> --authentication-code-2 <second-code>


Assuming this runs successfully, you should now have an image of a QR code open, a file called .credentials-ops that you can source
at any time so that you are using that account, and a line printed out in your terminal window explaining what you need to do next
(if the QR code does not open, you should be able to find it at /tmp/ops\_MFA.png.  At this point, you need to scan the QR code in
mfa.png with your MFA application (e.g. google authenticator), and then execute the command printed out when you ran create\_user.sh
with two consecutive authentication codes from your MFA application.

        ➜ aws iam enable-mfa-device --user-name ops --serial-number arn:aws:iam::123123123:mfa/ops --profile secure-aws-admin --authentication-code-1 12345 --authentication-code-2 2345

The ops users should now be ready to go and able to assume roles in your other accounts. You can do this manually with `aws sts assume-role`,
but we also provide a script to wrap these, albeit one that requires some configuration before you use it. Check `assume_role.sh` for more
details on configuration. Once you've set the various necessary parameters in `assume_role.sh` you can assume a role in another account as
follows:

        ➜ . ./.credentials-ops
        ➜ . ./assume_role.sh <target-account-number> Ops <current-mfa-token>

At this point your shell will be set up to use the temporary credentials for the target account. You can validate this by running these
commands:

        ➜ aws s3 mb s3://test-bucket-1123123123

Because the user has permission to assume role, and the role has power user access, it allows you create the bucket.

For more information on MFA with the CLI, see the [AWS instructions](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/).

## Creating and testing a DevAdmins user
Add a dev user duplicating the above process but with the following commands:

       ➜ ./create_user.sh dev DevAdmins
       
Note that this will create files .credentials-dev and /tmp/dev\_MFA.png. To test that this works,
we can perform the same steps we did with the ops user.

        ➜ . ./.credentials-ops
        ➜ . ./assume_role.sh <target-account-number> DevAdmin <current-mfa-token>
        ➜ aws s3 mb s3://test-bucket-11231231235

The call to make the bucket should fail because the user doesn't have permission.

If you would like to assume a role with any of the accounts using the console, you will need to be logged in as one of the defined users and then visit 
https://signin.aws.amazon.com/switchrole?account=[accountId]&roleName=[RoleForThatUser]. 
For this to work, you need to create [login profiles](http://docs.aws.amazon.com/cli/latest/reference/iam/create-login-profile.html) 
for the user.
