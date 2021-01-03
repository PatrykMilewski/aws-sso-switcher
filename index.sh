#!/bin/bash

source aws-sso-switcher-commons

# unset vars because will be run in parent shell context using source command
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset profile
unset CREDS

clearCacheSwitch="false"
while :; do
  case "${1:-}" in
    --profile)
      profile="${2}"
      shift
      ;;
    --clear-cache)
      clearCacheSwitch="${2}"
      shift
      ;;
    *)
      break
  esac
  shift
done
[ -z "$profile" ] && die "No profile provided"

if [ "$clearCacheSwitch" = "true" ]; then
  clearCache "$profile"
fi

log INFO "Getting temporary credentials for profile ${profile}"
grep -q "\[profile ${profile}\]" ~/.aws/config || die "Profile not found"

getCreds "$profile" "true"

[ -z "$CREDS" ] && die "Failed to load temporary credentials"

AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq .Credentials.AccessKeyId -r)
[ -z "$AWS_ACCESS_KEY_ID" ] && die "Failed to load AWS_ACCESS_KEY_ID"

AWS_SECRET_ACCESS_KEY=$(echo "$CREDS"  | jq .Credentials.SecretAccessKey -r)
[ -z "$AWS_SECRET_ACCESS_KEY" ] && die "Failed to load AWS_SECRET_ACCESS_KEY"

AWS_SESSION_TOKEN=$(echo "$CREDS"  | jq .Credentials.SessionToken -r)
[ -z "$AWS_SESSION_TOKEN" ] && die "Failed to load AWS_SESSION_TOKEN"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN