# Secure AWS Configuration Reference implementation

working off of [this article](https://thoughtworks.jiveon.com/people/mheiber/blog/2016/06/23/using-aws-with-security-as-a-first-class-citizen)
by Moritz. Will add more to the README later.

This aims to illustrate setting up a nice secure AWS configuration, with separate accounts for IAM and resource manipulation and all that good stuff.
Some parts can't be automated, so in the README we'll explain those bits.

## Prereqs
1. 2 AWS accounts

## Manual Steps
1. [Create an admin user](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) for each account.
This is important because you don't want to be using the root user to change these accounts.
2. Decide which account is going to be which. One account is going to handle IAM and nothing else, and the other will handle everything
except IAM.
3. Put AWS admin user access keys in ~/.aws/credentials with the IAM account as 'secure-aws-admin' and the second account as 'secure-aws-prod'
(See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles for an example.  Replace user2 with secure-aws-admin.)
4. Terraform should be happy now. Note however that to actually use the "dev" user to assume roles you will need to manually set up MFA and password.


## Using what you've got
To assume the role on the prod account, you will need to be logged in as the "dev" user and then visit
https://signin.aws.amazon.com/switchrole?account=[prodAccountId]&roleName=CrossAccountSignin
