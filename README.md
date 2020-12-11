# aws-sso-switcher

### Usage

```bash
. sso-switch \
  --profile <aws-profile-name>  # AWS profile name, that can be found in ~/.aws/config
  --duration <seconds>          # (Optional) How long does temp-credentials must be valid for, default 3600 seconds
```

### Install and Setup

```bash
npm install -g aws-sso-switcher
```
Then set up your `~/.aws/config` to have profiles with SSO configuration.

### How it works?

To workaround problems with Serverless Framework and other tools, when trying to use AWS CLI v2 SSO feature,
this script simply exports:
```bash
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```
which later are used in your shell. Values for those variables are extracted out of Credentials,
that are obtained with `aws sts assume-role` call.

#### Warning

To make it work, you need to have those env variables set in your current session. Because of this, if you simply
run `sso-switch` without dot and space before command, it will start a new process, which will have those set up,
but after process is finished, it will be simply cleared and won't affect your current process.

That's why it's improtant to use it this way `. sso-switch`
