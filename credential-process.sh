#!/bin/bash

source aws-sso-switcher-commons

unset profile
unset CREDS

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

[ -z "$profile" ] && die "ERROR: No profile provided"

getCreds "$profile"

[ -z "$CREDS" ] && die "ERROR: Failed to load temporary credentials"

echo "$CREDS" | jq '.Credentials + {Version: 1}' -r
