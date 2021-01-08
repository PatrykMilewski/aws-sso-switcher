#!/bin/bash

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

profile=$AWS_PROFILE
unset AWS_PROFILE
unset CREDS

credential_process=$(aws configure get profile."${profile}".credential_process)

[ -z "$profile" ] && die "ERROR: AWS_PROFILE not set"
CREDS=$(exec $credential_process)

[ -z "$CREDS" ] && die "Failed to load temporary credentials"

AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq .AccessKeyId -r)
[ -z "$AWS_ACCESS_KEY_ID" ] && die "Failed to load AWS_ACCESS_KEY_ID"

AWS_SECRET_ACCESS_KEY=$(echo "$CREDS"  | jq .SecretAccessKey -r)
[ -z "$AWS_SECRET_ACCESS_KEY" ] && die "Failed to load AWS_SECRET_ACCESS_KEY"

AWS_SESSION_TOKEN=$(echo "$CREDS"  | jq .SessionToken -r)
[ -z "$AWS_SESSION_TOKEN" ] && die "Failed to load AWS_SESSION_TOKEN"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

exec "$@"
