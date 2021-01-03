# aws-sso-switcher
<a href="https://www.npmjs.com/package/aws-sso-switcher">
  <img src="https://img.shields.io/npm/v/aws-sso-switcher.svg" />
</a>

### Install and Setup

```bash
npm install -g aws-sso-switcher
```
Then set up your `~/.aws/config` to have profiles with SSO configuration, like in example:
```
[profile your-profile-sso]
role_arn=arn:aws:iam::123456789012:role/ssoRoleName
source_profile=sso-source-profile-name
region=eu-west-1

[profile your-profile]
credential_process = sso-credential-process --profile your-profile-sso

[profile sso-source-profile-name]
sso_start_url = https://example.com
sso_region = eu-central-1
sso_account_id = 123456789012
sso_role_name = SSORoleName
region = eu-west-1
```

Now:
- `your-profile` can be used, by simply pointing it by `AWS_PROFILE=your-profile` or any other way
  of choosing active profile supported by AWS SDK/CLI (`aws s3 ls --profile your-profile`)
- `your-profile-sso` can be used normally by sourcing env variables with credentials, when you can simply 
  call `source sso-switch --profile your-profile-sso`, then credentials will be available for the console
  session, that called the command

### How it works?

#### sso-credential-process

AWS CLI/SDK supports sourcing credentials by using external process, as it's described in
[AWS docs.](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html)

This tool uses this approach, which makes SSO transparent to developer.

If you are having any problems with `sso-credential-process`, simply check if command 
`sso-credential-process --profile your-profile-sso` outputs correct JSON with credentials or try removing the cache.

#### sso-switch

To workaround problems with Serverless Framework and other tools, when trying to use AWS CLI v2 SSO feature,
this script simply exports:
```bash
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```
which later are used in your shell. Values for those variables are extracted out of temporary Credentials,
that are obtained with `aws sts assume-role` call.

You need to have those env variables set in your current session. Because of this, if you simply run 
`sso-switch` without `source` before command, it will start a new process, which will have those set up, but 
after process is finished, it will be simply cleared and won't affect your current process.

That's why it's important to use it this way `source sso-switch`

### Debugging Jetbrains IDEs (Webstorm, IntelliJ, Pycharm etc.)

Simply use profile without `sso` suffix, by setting up env variable `AWS_PROFILE=your-profile`

### Caching

This tool is caching credentials for 30 minutes in `~/.aws/sso-switcher/cache` directory, because without caching 
AWS CLI/SDK will always fetch new session tokens, which is very slow.

Manually caching in that case is officially recommended in 
[AWS docs.](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html)

Cache can be cleared using this switch:
```
source sso-switch \
  --profile <aws-profile-name> \
  --clear-cache "true"
```