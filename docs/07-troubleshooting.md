# Troubleshooting

## Pipeline fails at "Repo Pull" stage

| Error | Cause | Fix |
|---|---|---|
| `Permission denied (publickey)` | GitHub credentials missing/wrong | Verify `prod/github/credential` secret values |
| `Could not find credentials entry with ID 'prod/github/credential'` | Tag missing or plugin not seeing secret | Check `jenkins:credentials:type = usernamePassword` tag |
| `Repository not found` | Repo URL wrong or token lacks access | Verify URL and token scopes |

## Pipeline fails at "Build" stage

| Error | Cause | Fix |
|---|---|---|
| `mvn: command not found` | Maven not installed on Jenkins agent | `sudo yum install -y maven` |
| `Compilation failure` | Code issue | Check the Maven output for specifics |
| `Out of memory` | Default heap too small | Add `MAVEN_OPTS='-Xmx1024m'` to environment |

## Pipeline fails at "Push to JFrog" stage

| Error | Cause | Fix |
|---|---|---|
| `401 Bad Credentials` | Wrong username/password | Verify `prod/jfrog/credential` values |
| `Token length: 4` | Token stored as literal "null" — JSON key mismatch | Ensure JSON keys are exactly `username` and `password` |
| `403 Forbidden` | Token valid but lacks deploy permission | Check user has Deploy permission on the repo |
| `405 Method Not Allowed` | Pushing release to snapshot repo or vice versa | Check Handle Releases/Snapshots settings on the repo |
| `curl: (6) Could not resolve host` | DNS or network issue | Check EC2 can reach trialbi5kro.jfrog.io |

## Pipeline fails at "Notify Slack" stage

| Error | Cause | Fix |
|---|---|---|
| `invalid_payload` | JSON syntax error in message | Check the JSON in the curl --data, validate at jsonlint.com |
| `channel_not_found` | Slack app was uninstalled | Regenerate webhook URL in Slack app config |
| `Could not find credentials entry with ID 'prod/slack/webhook'` | Missing tag on AWS secret | Add `jenkins:credentials:type = string` tag |

## Diagnostic commands

### Test all secrets from EC2

```bash
./scripts/verify-aws-secrets.sh
```

### Test JFrog auth directly

```bash
USER=$(aws secretsmanager get-secret-value \
  --secret-id prod/jfrog/credential --region us-east-1 \
  --query SecretString --output text | jq -r '.username')
TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id prod/jfrog/credential --region us-east-1 \
  --query SecretString --output text | jq -r '.password')

curl -u "$USER:$TOKEN" https://trialbi5kro.jfrog.io/artifactory/api/system/ping
```

Expected: `OK`

### Test Slack webhook directly

```bash
URL=$(aws secretsmanager get-secret-value \
  --secret-id prod/slack/webhook --region us-east-1 \
  --query SecretString --output text | jq -r '.url')

curl -X POST -H 'Content-Type: application/json' \
  --data '{"text":"Diagnostic test"}' "$URL"
```

Expected: `ok`
