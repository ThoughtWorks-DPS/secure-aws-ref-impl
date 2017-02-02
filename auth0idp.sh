#!/bin/bash

AUTH0_TENANT=manderso
test -e auth0payload.json || { echo "Please follow the instructions in the readme for how to get the OpenId Connect payload to authenticate with Auth0."; exit 1; }
hash brew 2>/dev/null || { echo "INSTALL BREW YOU MONSTER"; exit 1; }
hash jq 2>/dev/null || brew install jq
ACCESS_TOKEN=$(curl -H "content-type: application/json" -X POST https://$AUTH0_TENANT.auth0.com/oauth/token -d '@auth0payload.json' | jq -r '.access_token')

APP_ID=$(curl -H "content-type: application/json" -H "authorization: Bearer $ACCESS_TOKEN" -X POST https://manderso.auth0.com/api/v2/clients -d "{\"name\": \"AWS Federated ID\"}" | jq -r '.client_id')

curl -H "content-type: application/json" -H "authorization: Bearer $ACCESS_TOKEN" -X PATCH https://$AUTH0_TENANT.auth0.com/api/v2/clients/$APP_ID -d "{\"callbacks\": [\"https://signin.aws.amazon.com/saml\"],\"addons\": {\"samlp\": $(cat aws-samlp-payload.json)}}"

curl -H "content-type: application/json" -H "authorization: Bearer $ACCESS_TOKEN" https://$AUTH0_TENANT.auth0.com/samlp/metadata/$APP_ID > metadata.xml
