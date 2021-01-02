#!/bin/bash

assumeRole() {
  local profile=$1
  local echoDetails=$2
  local sourceProfile=$(aws configure get profile."${profile}".source_profile)
  local roleArn=$(aws configure get profile."${profile}".role_arn)
  if [ "$echoDetails" == "true" ]; then
    echo "roleArn = ${roleArn}"
    echo "sourceProfile = ${sourceProfile}"
  fi
  creds=$(aws sts assume-role --profile "${sourceProfile}" --role-arn "${roleArn}" --role-session-name console-temp-role 2>&1)
  return_code=$?
  if [ ! $return_code -eq 0 ]; then
    if echo "$creds" | grep -q "expired"; then
      aws sso login --profile "$sourceProfile" > /dev/null 2>&1
      creds=$(aws sts assume-role --profile "${sourceProfile}" --role-arn "${roleArn}" --role-session-name console-temp-role 2>&1)
    else
      echo "Failed to fetch temporary credentials by assuming role ${roleArn} from profile ${sourceProfile}"
      exit 1
    fi
  fi
  CREDS="$creds"
  export CREDS
}
