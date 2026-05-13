#!/bin/bash
# Verify all three AWS secrets exist and are readable

set -e

REGION="us-east-1"
SECRETS=("prod/github/credential" "prod/jfrog/credential" "prod/slack/webhook")

echo "===== AWS Secrets Verification ====="
echo "Region: $REGION"
echo ""

for SECRET in "${SECRETS[@]}"; do
    echo "Checking: $SECRET"
    
    if ! VALUE=$(aws secretsmanager get-secret-value \
        --secret-id "$SECRET" \
        --region "$REGION" \
        --query SecretString --output text 2>/dev/null); then
        echo "  ❌ NOT ACCESSIBLE (check IAM role or secret name)"
        continue
    fi
    
    echo "  ✅ Readable"
    
    # Verify structure
    case "$SECRET" in
        */github/credential)
            USERNAME=$(echo "$VALUE" | jq -r '.username // empty')
            TOKEN=$(echo "$VALUE" | jq -r '.secret // empty')
            [ -n "$USERNAME" ] && echo "  ✅ username: present (${#USERNAME} chars)" || echo "  ❌ username: missing"
            [ -n "$TOKEN" ] && echo "  ✅ token: present (${#TOKEN} chars)" || echo "  ❌ token: missing"
            ;;
        */jfrog/credential)
            USERNAME=$(echo "$VALUE" | jq -r '.username // empty')
            TOKEN=$(echo "$VALUE" | jq -r '.password // empty')
            [ -n "$USERNAME" ] && echo "  ✅ username: present (${#USERNAME} chars)" || echo "  ❌ username: missing"
            [ -n "$TOKEN" ] && echo "  ✅ token: present (${#TOKEN} chars)" || echo "  ❌ token: missing"
            ;;
        */slack/webhook)
            URL=$(echo "$VALUE" | jq -r '.url // empty')
            [ -n "$URL" ] && echo "  ✅ url: present (${#URL} chars)" || echo "  ❌ url: missing"
            ;;
    esac
    echo ""
done

echo "===== Done ====="
