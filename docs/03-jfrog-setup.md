# JFrog Setup

## Step 1: Create a Maven snapshot repository

In JFrog UI:

1. Navigate to **Administration → Repositories → Repositories**
2. Click **Create a Repository → Local**
3. Select **Maven** package type
4. Configuration:
   - Repository Key: `democode-libs-snapshot`
   - Handle Releases: ❌ unchecked
   - Handle Snapshots: ✅ checked
   - Maven Snapshot Version Behavior: `Unique`
5. Click **Create Local Repository**

(Optionally also create `democode-libs` for release versions, with the opposite
Handle settings.)

## Step 2: Generate an identity token

1. JFrog UI → **Administration → Access Tokens**
2. Click **+ Generate Token**
3. Fill in:
   - Description: `jenkins-ci-deploy`
   - Token scope: **User**
   - User name: your JFrog username (e.g., `tparuchu@depaul.edu`)
   - Service: All (default)
   - Expiration time: Custom, **8760 hours** (1 year)
   - ✅ Check **Create Reference Token**
4. Click **Generate**
5. **Copy the Reference Token using the copy button** (NOT manual select — it
   truncates the value)
6. Paste it into the `prod/jfrog/credential` AWS secret under the `password` key

## Step 3: Verify token works

From your EC2 or local machine:

```bash
USER=$(aws secretsmanager get-secret-value \
  --secret-id prod/jfrog/credential --region us-east-1 \
  --query SecretString --output text | jq -r '.username')
TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id prod/jfrog/credential --region us-east-1 \
  --query SecretString --output text | jq -r '.password')

curl -u "$USER:$TOKEN" https://trialbi5kro.jfrog.io/artifactory/api/system/ping
```

Expected output: `OK`

## Why we use curl instead of `mvn deploy`

For this learning setup, we upload the JAR directly via `curl` instead of using
Maven's `deploy` plugin. Trade-offs:

| Approach | Pros | Cons |
|---|---|---|
| `curl -T file.jar` (what we use) | Simple, transparent, no pom.xml changes | No `.pom` published — not a "proper" Maven artifact |
| `mvn deploy` (production-grade) | Full Maven metadata, dependency graph | Requires `<distributionManagement>` in pom.xml and settings.xml |

For production library publishing, use `mvn deploy`. For learning or for
deploying self-contained applications, `curl` is fine.
