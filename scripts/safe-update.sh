#!/bin/bash

# Safe infrastructure update script
# This will create missing tables without affecting existing resources

set -e

STACK_NAME="vehicle-guesser-backend"
REGION="eu-west-1"

echo "🔍 Checking current stack status..."
aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION > /dev/null 2>&1 || {
    echo "❌ Stack $STACK_NAME not found. Please deploy it first."
    exit 1
}

echo "✅ Stack found. Creating change set..."

# Create change set to preview changes
CHANGE_SET_NAME="add-missing-tables-$(date +%s)"
aws cloudformation create-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --template-body file://templates/backend-updated.yml \
    --capabilities CAPABILITY_IAM \
    --region $REGION

echo "⏳ Waiting for change set to be created..."
aws cloudformation wait change-set-create-complete \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --region $REGION

echo ""
echo "📋 Changes to be applied:"
aws cloudformation describe-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --region $REGION \
    --query 'Changes[*].[ResourceChange.Action,ResourceChange.LogicalResourceId,ResourceChange.ResourceType]' \
    --output table

echo ""
read -p "Do you want to apply these changes? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Deployment cancelled"
    aws cloudformation delete-change-set \
        --stack-name $STACK_NAME \
        --change-set-name $CHANGE_SET_NAME \
        --region $REGION
    exit 0
fi

echo "🚀 Applying changes..."
aws cloudformation execute-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --region $REGION

echo "⏳ Waiting for stack update to complete..."
aws cloudformation wait stack-update-complete \
    --stack-name $STACK_NAME \
    --region $REGION

echo "✅ Infrastructure update completed successfully!"
echo ""
echo "📊 New resources created:"
aws cloudformation describe-stack-resources \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'StackResources[?ResourceType==`AWS::DynamoDB::Table`].[LogicalResourceId,PhysicalResourceId]' \
    --output table
