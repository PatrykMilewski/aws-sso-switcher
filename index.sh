#!/bin/bash
# unset vars because will be run in parent shell context using source command
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset profile
unset role_arn
unset source_profile
while :; do
  case "${1:-}" in
    --profile)
      profile="${2}"
      shift
      ;;
    --duration)
      duration=${3}
      shift
      ;;
    *)
      break
  esac
  shift
done
[ -z "$profile" ] && echo "ERROR: No profile provided"
echo "Getting temp credentials for profile ${profile}"
grep "\[profile ${profile}\]" ~/.aws/config || echo "ERROR: Profile not found"
eval $(grep = <(grep -A3 "\[profile ${profile}\]" ~/.aws/config))
echo "role_arn = ${role_arn}"
echo "source_profile = ${source_profile}"

creds=$(aws sts assume-role --profile "${source_profile}" --role-arn "${role_arn}" --role-session-name console-temp-role --duration-seconds duration)

AWS_ACCESS_KEY_ID=$(echo "$creds" | jq .Credentials.AccessKeyId -r)
[ -z "$AWS_ACCESS_KEY_ID" ] && echo "ERROR: Failed to load AWS_ACCESS_KEY_ID"
export AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY=$(echo "$creds"  | jq .Credentials.SecretAccessKey -r)
[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "ERROR: Failed to load AWS_SECRET_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY

AWS_SESSION_TOKEN=$(echo "$creds"  | jq .Credentials.SessionToken -r)
[ -z "$AWS_SESSION_TOKEN" ] && echo "ERROR: Failed to load AWS_SESSION_TOKEN"
export AWS_SESSION_TOKEN
