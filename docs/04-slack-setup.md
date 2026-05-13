# Slack Setup

## Step 1: Create a Slack app

1. Go to https://api.slack.com/apps
2. Click **Create New App → From scratch**
3. Name: `SRE CICD notification App`
4. Choose your workspace
5. Click **Create App**

## Step 2: Enable Incoming Webhooks

1. In the app config page, click **Incoming Webhooks** in the left sidebar
2. Toggle **Activate Incoming Webhooks** to **On**
3. Scroll down → click **Add New Webhook to Workspace**
4. Select the channel (e.g., `#ci-notifications`)
5. Click **Allow**

## Step 3: Copy the webhook URL

Slack returns to the Incoming Webhooks page. Find your webhook in the list and
click **Copy** next to the URL. It will look like:
