#!/bin/bash

# Change to the ansible directory
cd ~/Downloads/Cloudsprint/ansible

# Set AWS credentials
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
export AWS_DEFAULT_REGION="eu-north-1"

# Start timestamp
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "🚀 Starting deployment: $START_TIME"

# Try to install the required collection if missing
if ! ansible-galaxy collection list | grep -q "community.aws"; then
    echo "📦 Installing community.aws collection..."
    ansible-galaxy collection install community.aws -f
fi

# Run the Ansible playbook but skip the logging tasks if they fail
ansible-playbook playbooks/deploy-wordpress.yml -v \
  --extra-vars "deployment_start_time=$START_TIME" \
  --skip-tags logging

# Check if the playbook ran successfully
if [ $? -eq 0 ]; then
    # End timestamp
    END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "✅ Deployment completed successfully: $END_TIME"
    
    # Log to CloudWatch using AWS CLI instead of Ansible module
    TIMESTAMP=$(date +%s000)
    MESSAGE="DEPLOYMENT_COMPLETED: Start=$START_TIME, End=$END_TIME, Status=SUCCESS"
    
    aws logs put-log-events \
      --log-group-name "/ansible/deployments" \
      --log-stream-name "deployment-timeline" \
      --log-events "[{\"timestamp\": $TIMESTAMP, \"message\": \"$MESSAGE\"}]" \
      --region eu-north-1 2>/dev/null || echo "⚠️  CloudWatch logging failed, but deployment succeeded"
else
    # End timestamp for failed deployment
    END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "❌ Deployment failed: $END_TIME"
    
    # Log failure to CloudWatch using AWS CLI
    TIMESTAMP=$(date +%s000)
    MESSAGE="DEPLOYMENT_FAILED: Start=$START_TIME, End=$END_TIME, Status=FAILED"
    
    aws logs put-log-events \
      --log-group-name "/ansible/deployments" \
      --log-stream-name "deployment-timeline" \
      --log-events "[{\"timestamp\": $TIMESTAMP, \"message\": \"$MESSAGE\"}]" \
      --region eu-north-1 2>/dev/null || echo "⚠️  CloudWatch logging failed"
    
    exit 1
fi
