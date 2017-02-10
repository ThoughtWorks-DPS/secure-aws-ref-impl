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
`secure-aws-preprod`, and `secure-aws-infra`, corresponding to the purpose of each of the accounts.
(See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles for an example.  Replace user2 with secure-aws-admin.)


## Using what you've got
To assume a role on any of the account, you will need to be logged in as one of the defined users and then visit
https://signin.aws.amazon.com/switchrole?account=[accountId]&roleName=[RoleForThatUser]
