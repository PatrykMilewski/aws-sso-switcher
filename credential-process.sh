#!/bin/bash

. sso-switch-commons

unset profile

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

[ -z "$profile" ] && echo "ERROR: No profile provided"

assumeRole "$profile"

[ -z "$CREDS" ] && echo "ERROR: Failed to load temporary credentials"

echo "$CREDS" | jq '.Credentials + {Version: 1}' -r
