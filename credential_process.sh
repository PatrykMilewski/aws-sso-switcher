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
      shift;;
    *)
      break
  esac
  shift
done

[ -z $profile ] && echo "ERROR: No profile provided"


role_arn=$(aws configure get ${profile}.role_arn)
source_profile=$(aws configure get ${profile}.source_profile)

creds=$(aws sts assume-role --profile ${source_profile} --role-arn ${role_arn} --role-session-name console-temp-role 2>&1)
return_code=$?
if [ ! $return_code -eq 0 ] 
then
   if echo $creds | grep "expired"; then
    aws sso login --profile $source_profile
    creds=$(aws sts assume-role --profile ${source_profile} --role-arn ${role_arn} --role-session-name console-temp-role 2>&1)
   fi
fi

export AWS_ACCESS_KEY_ID=$(echo $creds | jq .Credentials.AccessKeyId -r) 
export AWS_SECRET_ACCESS_KEY=$(echo $creds  | jq .Credentials.SecretAccessKey -r) 
export AWS_SESSION_TOKEN=$(echo $creds  | jq .Credentials.SessionToken -r)

echo $creds | jq '.Credentials + {Version: 1}' -r

