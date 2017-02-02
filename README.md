# Secure AWS Configuration Reference implementation

working off of [this article](https://thoughtworks.jiveon.com/people/mheiber/blog/2016/06/23/using-aws-with-security-as-a-first-class-citizen)
by Moritz. Will add more to the README later.

## Prereqs
1. An AWS account with root admin
2. An Auth0 account, as we're going to use Auth0 for identity federation

## Manual Steps
1. Create admin user through AWS console.
2. Delete root access keys
3. Put AWS admin user access keys in ~/.aws/credentials under role 'secure-aws-admin' (See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles for an example.  Replace user2 with secure-aws-admin.)
4. Get the JSON payload for OpenID Connect auth negotiation from Auth0. If you're signed in, you can
go to https://manage.auth0.com/#/apis/, then click the _Auth0 Management API_ link, then go to the _Test_ tab.
(If you haven't before you may have to create a test client now.)
The first curl request shown includes a `--data` parameter, the content of which is the necessary payload.
Save this as auth0payload.json in the root of this directory and you're good to go.
