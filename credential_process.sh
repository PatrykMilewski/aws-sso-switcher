#!/bin/bash

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

echo $creds | jq '.Credentials + {Version: 1}' -r

