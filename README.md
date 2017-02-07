# Secure AWS Configuration Reference implementation

working off of [this article](https://thoughtworks.jiveon.com/people/mheiber/blog/2016/06/23/using-aws-with-security-as-a-first-class-citizen)
by Moritz. Will add more to the README later.

## Prereqs
1. An AWS account with root admin

## Manual Steps
1. [Create an admin user](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
2. Delete root access keys if they are still lying around
3. Put AWS admin user access keys in ~/.aws/credentials under role 'secure-aws-admin' (See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles for an example.  Replace user2 with secure-aws-admin.)
