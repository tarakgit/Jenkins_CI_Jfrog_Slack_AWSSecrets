# Jenkins_CI_Jfrog_Slack_AWSSecrets
A reference Jenkins pipeline that builds a Java Maven project, publishes the artifact to JFrog Artifactory, and notifies a Slack with AWS secret

# SRE CI/CD Pipeline: GitHub → Jenkins → JFrog → Slack

A reference Jenkins pipeline that builds a Java Maven project, publishes the
artifact to JFrog Artifactory, and notifies a Slack channel — with all
credentials managed through AWS Secrets Manager.

## What this pipeline does
## Quick start

1. Clone this repo
2. Follow the setup guides in `docs/` in numerical order
3. Create a Jenkins pipeline pointing to the `Jenkinsfile` in this repo
4. Trigger a build — the artifact lands in JFrog and a Slack message appears

## Repository contents

| File / Folder | Purpose |
|---|---|
| `Jenkinsfile` | The pipeline definition (Declarative Pipeline syntax) |
| `docs/` | Step-by-step setup and operations documentation |
| `scripts/` | Helper scripts for testing and verification |
| `.gitignore` | Files to exclude from version control |

## Architecture at a glance

- **Source control**: GitHub (`github.com/tarakgit/simple-java-maven-app`)
- **CI orchestrator**: Jenkins running on EC2 (`3.208.86.231:8080`)
- **Credential vault**: AWS Secrets Manager (region `us-east-1`)
- **Artifact repository**: JFrog Artifactory (`trialbi5kro.jfrog.io`)
- **Notification channel**: Slack via incoming webhook

See `docs/01-architecture.md` for full details.

## Documentation index

1. [Architecture overview](docs/01-architecture.md)
2. [AWS Secrets Manager setup](docs/02-aws-secrets-setup.md)
3. [JFrog setup](docs/03-jfrog-setup.md)
4. [Slack setup](docs/04-slack-setup.md)
5. [Jenkins setup](docs/05-jenkins-setup.md)
6. [Running the pipeline](docs/06-running-the-pipeline.md)
7. [Troubleshooting](docs/07-troubleshooting.md)

## Author

Tarak Paruchu (tparuchu@depaul.edu)

## License

MIT (or whichever you prefer)
