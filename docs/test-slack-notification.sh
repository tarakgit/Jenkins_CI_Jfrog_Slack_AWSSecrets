#!/bin/bash
# Test that Slack notification works end-to-end from the EC2 host

set -e

URL=$(aws secretsmanager get-secret-value \
  --secret-id prod/slack/webhook \
  --region us-east-1 \
  --query SecretString --output text | jq -r '.url')

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "❌ Could not retrieve Slack URL from AWS Secrets Manager"
    exit 1
fi

echo "Posting test message to Slack..."

RESPONSE=$(curl -s -X POST -H 'Content-Type: application/json' \
  --data '{"text":"🧪 Test notification from verify script. If you see this, Slack integration works."}' \
  "$URL")

if [ "$RESPONSE" = "ok" ]; then
    echo "✅ Slack notification sent successfully — check your channel"
else
    echo "❌ Slack returned: $RESPONSE"
    exit 1
fi
