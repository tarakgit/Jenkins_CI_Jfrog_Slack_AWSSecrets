# AWS Secrets Manager Setup

This pipeline reads three secrets at runtime. All three live in
AWS Secrets Manager in region `us-east-1`.

## Prerequisites

- AWS account with permission to create secrets
- The Jenkins EC2 instance must have an IAM role with this policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecrets",
      
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:*:secret:prod/github/*",
                "arn:aws:secretsmanager:us-east-1:*:secret:prod/jfrog/*",
                "arn:aws:secretsmanager:us-east-1:*:secret:prod/slack/*"
            ]
        }
    ]
}
```

## Secret 1: GitHub credentials

| Property | Value |
|---|---|
| **Name** | `prod/github/credential` |
| **Region** | `us-east-1` |
| **Tag** | `jenkins:credentials:type = usernamePassword` |
| **JSON value** | `{"username": "<your-github-username>", "secret": "<github-personal-access-token>"}` |

**Generate the GitHub token at:** https://github.com/settings/tokens
Required scope: `repo` (full control of private repositories)

## Secret 2: JFrog credentials

| Property | Value |
|---|---|
| **Name** | `prod/jfrog/credential` |
| **Region** | `us-east-1` |
| **Tag** | `jenkins:credentials:type = usernamePassword` |
| **JSON value** | `{"username": "<your-jfrog-username>", "password": "<jfrog-reference-token>"}` |

**Generate the JFrog token at:** JFrog UI → Administration → Access Tokens → Generate Token
Important settings:
- Token scope: User
- Service: All
- Expiration: 8760 hours (1 year)
- ✅ Check "Create Reference Token"
- Use the **Reference Token** value (shorter, ~64 chars)

## Secret 3: Slack webhook URL

| Property | Value |
|---|---|
| **Name** | `prod/slack/webhook` |
| **Region** | `us-east-1` |
| **Tag** | `jenkins:credentials:type = string` |
| **JSON value** | `{"url": "https://hooks.slack.com/services/T01.../B02.../xyz..."}` |

**Generate the Slack webhook at:** see `docs/04-slack-setup.md`

## Verifying all secrets exist

Run this on the Jenkins EC2 to verify all three secrets are readable:

```bash
for SECRET in prod/github/credential prod/jfrog/credential prod/slack/webhook; do
    echo "Checking $SECRET..."
    aws secretsmanager get-secret-value \
        --secret-id "$SECRET" \
        --region us-east-1 \
        --query SecretString --output text > /dev/null \
        && echo "  ✅ Readable" \
        || echo "  ❌ Not accessible"
done
```

Expected output: three lines of `✅ Readable`.

## Common issues

| Error | Cause | Fix |
|---|---|---|
| `AccessDeniedException` | IAM role missing permission | Update IAM policy as shown above |
| `ResourceNotFoundException` | Secret name typo | Double-check spelling and region |
| `Token length: 4` | Secret value got truncated as "null" | Re-paste full value, use copy button |
