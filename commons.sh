#!/bin/bash

CACHE_DIRECTORY="${HOME}/.aws/sso-switcher/cache"

log() {
  local logLevel=$1
  local message=$2
  local date=$(date)
  echo "${date} ${logLevel} ${message}"
}

die() {
  log ERROR "$* (status $?)" 1>&2
  exit 1
}

assumeRole() {
  local profile=$1
  local echoDetails=$2
  local sourceProfile=$(aws configure get profile."${profile}".source_profile)
  local roleArn=$(aws configure get profile."${profile}".role_arn)
  if [ "$echoDetails" = "true" ]; then
    log INFO "roleArn = ${roleArn}"
    log INFO "sourceProfile = ${sourceProfile}"
  fi
  creds=$(aws sts assume-role --profile "${sourceProfile}" --role-arn "${roleArn}" --role-session-name console-temp-role 2>&1)
  return_code=$?
  if [ ! $return_code -eq 0 ]; then
    if echo "$creds" | grep -q "expired"; then
      aws sso login --profile "$sourceProfile" > /dev/null 2>&1
      creds=$(aws sts assume-role --profile "${sourceProfile}" --role-arn "${roleArn}" --role-session-name console-temp-role 2>&1)
    else
      die "Failed to fetch temporary credentials by assuming role ${roleArn} from profile ${sourceProfile}"
    fi
  fi
  CREDS="$creds"
  export CREDS
}

clearCache() {
  local profile=$1
  rm -f "${CACHE_DIRECTORY}/${profile}.json"
  rm -f "${CACHE_DIRECTORY}/${profile}-valid-until"
}

getCachedCreds() {
  local profile=$1
  if [ -f "${CACHE_DIRECTORY}/${profile}.json" ]; then
    local validUntil=$(cat "${CACHE_DIRECTORY}/${profile}-valid-until")
    local currentTime=$(date +'%s')
    if [ "$currentTime" -lt "$validUntil" ]; then
      CREDS=$(cat "${CACHE_DIRECTORY}/${profile}.json")
      export CREDS
    fi
  fi
}

updateCache() {
  local profile=$1
  local creds=$2
  if [ "$(echo "$creds" | jq empty > /dev/null 2>&1; echo $?)" -eq 0 ]; then
    (
      mkdir -p "${CACHE_DIRECTORY}"
      set -o noclobber
      echo "$creds" >| "${CACHE_DIRECTORY}/${profile}.json" 2>&1
      local currentTime=$(date +'%s')
      local validUntil=$((currentTime + 1800))
      echo "$validUntil" >| "${CACHE_DIRECTORY}/${profile}-valid-until" 2>&1
    )
  fi
}

getCreds() {
  local profile=$1
  local echoDetails=$2

  getCachedCreds "$profile"

  if [ -z "$CREDS" ]; then
    assumeRole "$profile" "$echoDetails"
    updateCache "$profile" "$CREDS"
  else
    if [ "$echoDetails" = "true" ]; then
      log INFO "Using cached credentials"
    fi
    export CREDS
  fi
}
