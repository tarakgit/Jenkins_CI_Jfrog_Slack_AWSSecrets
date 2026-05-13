# Jenkins Setup

## Prerequisites

- Jenkins running on EC2 (Amazon Linux 2/2023 recommended)
- Java 11 or later installed
- Maven installed (`mvn --version` should work)
- AWS CLI installed (`aws --version`)
- jq installed (`sudo yum install -y jq`)
- The EC2 instance has an IAM role with permission to read the AWS secrets
  (see `docs/02-aws-secrets-setup.md`)

## Required Jenkins plugins

Install via **Manage Jenkins → Plugins → Available**:

| Plugin | Purpose |
|---|---|
| **AWS Secrets Manager Credentials Provider** | Surfaces AWS secrets as Jenkins credentials |
| **Pipeline** | Core declarative pipeline support (usually pre-installed) |
| **Git** | Clones from GitHub (usually pre-installed) |

## Create the pipeline job

1. Jenkins → **New Item**
2. Name: `Jenkins-JFrog-Slack-Pipeline` (or anything)
3. Type: **Pipeline**
4. Click **OK**
5. In **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/<your-username>/sre-cicd-pipeline.git`
   - Credentials: select `prod/github/credential`
   - Branch: `*/master` (or `main`)
   - Script Path: `Jenkinsfile`
6. Save

## Verify the credentials are visible

Manage Jenkins → Credentials → System → AWS Secrets Manager. You should see:
- `prod/github/credential`
- `prod/jfrog/credential`
- `prod/slack/webhook`

If any are missing, check that the AWS secret has the correct
`jenkins:credentials:type` tag (see `docs/02-aws-secrets-setup.md`).
