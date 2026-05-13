# Running the Pipeline

## Trigger a build

1. Open the pipeline job in Jenkins
2. Click **Build Now** in the left sidebar
3. Watch the Stage View — each stage shows green as it completes

## Expected build output

| Stage | Expected duration | What it does |
|---|---|---|
| Cleanup | < 1s | Empties the workspace |
| Repo Pull | 2-5s | Clones the GitHub repo |
| Build | 30-60s | Runs `mvn clean install` |
| Test | 5-10s | Runs `mvn test` |
| Push to JFrog | 1-3s | Uploads JAR to JFrog |
| Notify Slack | < 1s | Posts to Slack channel |

## Where to verify success

1. **Jenkins console output** — should end with "✅ Pipeline complete"
2. **JFrog UI** — Application → Artifactory → Artifacts → `democode-libs-snapshot/test/`
   - You should see `my-app-N.jar` (where N is the build number)
3. **Slack channel** — a message should appear with the build details

## Sample Slack notification

> 🚀 **my-app-7.jar** pushed to JFrog
> • **Repo:** democode-libs-snapshot
> • **Path:** test
> • **Build:** #7
> • **Triggered by:** Jenkins on EC2

## Trigger automatically on GitHub push (optional)

To make Jenkins build automatically when code is pushed to GitHub:

1. In GitHub repo → Settings → Webhooks → Add webhook
2. Payload URL: `http://3.208.86.231:8080/github-webhook/`
3. Content type: `application/json`
4. Events: `Just the push event`
5. In Jenkins job config → **Build Triggers** → check
   **GitHub hook trigger for GITScm polling**
