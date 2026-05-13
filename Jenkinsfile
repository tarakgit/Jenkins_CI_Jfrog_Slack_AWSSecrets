pipeline {
    agent any
    
    environment {
        // ---------- Source repository ----------
        REPO_URL          = 'https://github.com/tarakgit/simple-java-maven-app.git'
        BRANCH            = 'master'
        GITHUB_CRED_ID    = 'prod/github/credential'
        
        // ---------- Build artifact ----------
        ARTIFACT_PATH     = 'target/my-app.jar'
        ARTIFACT_NAME     = 'my-app'
        
        // ---------- JFrog Artifactory ----------
        JFROG_URL         = 'https://trialbi5kro.jfrog.io/artifactory'
        JFROG_REPO        = 'democode-libs-snapshot'
        JFROG_PATH        = 'test'
        JFROG_SECRET_ID   = 'prod/jfrog/credential'
        
        // ---------- Slack notifications ----------
        SLACK_SECRET_ID   = 'prod/slack/webhook'
        
        // ---------- AWS ----------
        AWS_REGION        = 'us-east-1'
    }
    
    stages {
        stage('Cleanup') {
            steps { 
                deleteDir() 
            }
        }
        
        stage('Repo Pull') {
            steps {
                git(
                    url: "${REPO_URL}",
                    credentialsId: "${GITHUB_CRED_ID}",
                    branch: "${BRANCH}"
                )
            }
        }
        
        stage('Build') {
            steps { 
                sh 'mvn clean install -DskipTests'
            }
        }
        
        stage('Test') {
            steps { 
                sh 'mvn test'
            }
        }
        
        stage('Push to JFrog') {
            steps {
                sh '''
                    # Pull JFrog credentials from AWS Secrets Manager
                    SECRET_JSON=$(aws secretsmanager get-secret-value \
                        --secret-id "$JFROG_SECRET_ID" \
                        --region "$AWS_REGION" \
                        --query SecretString --output text)
                    
                    JFROG_USER=$(echo "$SECRET_JSON" | jq -r '.username')
                    JFROG_TOKEN=$(echo "$SECRET_JSON" | jq -r '.password')
                    
                    echo "Username length: ${#JFROG_USER}"
                    echo "Token length:    ${#JFROG_TOKEN}"
                    
                    # Upload artifact (hide token from logs)
                    set +x
                    curl -f -u "$JFROG_USER:$JFROG_TOKEN" \
                         -T "$ARTIFACT_PATH" \
                         "$JFROG_URL/$JFROG_REPO/$JFROG_PATH/${ARTIFACT_NAME}-${BUILD_NUMBER}.jar"
                    CURL_EXIT=$?
                    set -x
                    
                    exit $CURL_EXIT
                '''
            }
        }
        
        stage('Notify Slack') {
            steps {
                sh '''
                    # Pull Slack webhook URL from AWS Secrets Manager
                    SLACK_URL=$(aws secretsmanager get-secret-value \
                        --secret-id "$SLACK_SECRET_ID" \
                        --region "$AWS_REGION" \
                        --query SecretString --output text | jq -r '.url')
                    
                    # Post notification (hide URL from logs)
                    set +x
                    curl -X POST -H 'Content-Type: application/json' \
                      --data "{
                        \\"text\\": \\"🚀 *${ARTIFACT_NAME}-${BUILD_NUMBER}.jar* pushed to JFrog\\n• *Repo:* ${JFROG_REPO}\\n• *Path:* ${JFROG_PATH}\\n• *Build:* #${BUILD_NUMBER}\\n• *Triggered by:* Jenkins on EC2\\"
                      }" \
                      "$SLACK_URL"
                    set -x
                '''
            }
        }
    }
    
    post {
        success { 
            echo "✅ Pipeline complete — artifact in JFrog, team notified." 
        }
        failure { 
            echo "❌ Pipeline failed — check logs for the failed stage." 
        }
    }
}
