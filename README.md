# aws-sso-switcher

### Usage

```bash
source sso-switch \
  --profile <aws-profile-name>  # AWS profile name, that can be found in ~/.aws/config
```

Or if sourcing is not possible, jump to "How to use it, when sourcing env vars is not possible?" paragraph.

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

[profile sso-source-profile-name]
sso_start_url = https://example.com
sso_region = eu-central-1
sso_account_id = 123456789012
sso_role_name = SSORoleName
region = eu-west-1
```

### How it works?

To workaround problems with Serverless Framework and other tools, when trying to use AWS CLI v2 SSO feature,
this script simply exports:
```bash
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```
which later are used in your shell. Values for those variables are extracted out of temporary Credentials,
that are obtained with `aws sts assume-role` call.

#### Warning

You need to have those env variables set in your current session.
Because of this, if you simply run `sso-switch` without `source` before command, it will start a new process,
which will have those set up, but after process is finished, it will be simply cleared and won't affect your current process.

That's why it's important to use it this way `source sso-switch`

### How to use it, when sourcing env vars is not possible?

If the application, that you are using, cannot source env variables with credentials before running something,
then you have to create 2 separate profiles as you can see on the example:
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
- `your-profile-sso` can be used normally, when you can simply call `source sso-switch --profile your-profile-sso`
- `your-profile` can be used in applications, by simply pointing it by `AWS_PROFILE=your-profile` or any other way
of choosing active profile supported by AWS SDK
  
### Jetbrains IDEs (Webstorm, IntelliJ, Pycharm etc.)

Because those IDEs doesn't support sourcing the env variables before running tests for example, you have to use the
second way, that was presented in paragraph above.

To use the profile, simply export somewhere constant env variable `AWS_PROFILE=your-profile`

### Caching

This tool is caching credentials in case of using `sso-credential-process` for 30 minutes in 
`~/.aws/sso-switcher/cache` directory, because without caching AWS CLI/SDK will always fetch new session tokens,
which is very slow.

Thanks to this, for AWS CLI the delay is smaller by 2 seconds and for AWS SDK it's even bigger gain (around 4 seconds).

Caching cannot be disabled or configured.