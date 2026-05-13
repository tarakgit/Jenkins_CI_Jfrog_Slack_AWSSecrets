# Architecture Overview

## System diagram

┌──────────────┐
│   GitHub     │
│ (source code)│
└──────┬───────┘
│ git clone (with credentials from AWS)
↓
┌──────────────────────────────────────────┐
│           Jenkins (EC2)                  │
│  - Reads secrets from AWS Secrets Mgr    │
│  - Runs Maven build & tests              │
│  - Pushes artifact via curl              │
│  - Posts to Slack via curl               │
└─────┬──────────────────────┬─────────────┘
│                      │
│ curl upload          │ curl POST
↓                      ↓
┌──────────────┐      ┌──────────────┐
│    JFrog     │      │    Slack     │
│ Artifactory  │      │   channel    │
│ (artifact)   │      │(notification)│
└──────────────┘      └──────────────┘

↑
       │ all credentials retrieved at runtime
       │

┌──────────────────────────┐
│  AWS Secrets Manager     │
│  (us-east-1)             │
│  - prod/github/credential│
│  - prod/jfrog/credential │
│  - prod/slack/webhook    │
└──────────────────────────┘


## Components

| Component | Role | Hosted at |
|---|---|---|
| GitHub | Source code repository | github.com |
| Jenkins | Pipeline orchestrator | EC2 instance (us-east-1) |
| AWS Secrets Manager | Credential vault | AWS us-east-1 |
| JFrog Artifactory | Artifact storage | trialbi5kro.jfrog.io |
| Slack | Team notifications | hooks.slack.com |

## Why this architecture

- **No secrets in code or Jenkinsfile** — all retrieved at runtime from AWS
- **No manual credential management on Jenkins agents** — IAM role grants access
- **Single Jenkinsfile** — runs against multiple environments by swapping secret IDs
- **Auditable** — AWS CloudTrail logs every secret access

## Data flow per pipeline run

1. Developer triggers Jenkins build (manual or webhook)
2. Jenkins reads `prod/github/credential` from AWS, clones the repo
3. Maven compiles → tests → produces `target/my-app.jar`
4. Jenkins reads `prod/jfrog/credential`, uses curl to upload JAR
5. JFrog stores the artifact at `democode-libs-snapshot/test/my-app-N.jar`
6. Jenkins reads `prod/slack/webhook`, uses curl to post notification
7. Slack channel receives the message
