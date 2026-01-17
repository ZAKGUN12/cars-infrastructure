#!/bin/bash

# Add only the missing Matchmaking table

set -e

REGION="eu-west-1"
TABLE_NAME="vehicle-guesser-matchmaking-prod"

echo "🔍 Checking if $TABLE_NAME exists..."

if aws dynamodb describe-table --table-name $TABLE_NAME --region $REGION > /dev/null 2>&1; then
    echo "✅ Table already exists. Nothing to do."
    exit 0
fi

echo "📦 Creating $TABLE_NAME..."

aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --billing-mode PAY_PER_REQUEST \
    --attribute-definitions \
        AttributeName=userId,AttributeType=S \
        AttributeName=difficulty,AttributeType=S \
    --key-schema \
        AttributeName=userId,KeyType=HASH \
    --global-secondary-indexes \
        "IndexName=DifficultyIndex,KeySchema=[{AttributeName=difficulty,KeyType=HASH}],Projection={ProjectionType=ALL}" \
    --region $REGION

echo "⏳ Waiting for table to be active..."
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $REGION

echo "✅ Table created successfully!"

# Enable TTL
echo "⏰ Enabling TTL..."
aws dynamodb update-time-to-live \
    --table-name $TABLE_NAME \
    --time-to-live-specification "Enabled=true,AttributeName=ttl" \
    --region $REGION

echo ""
echo "✅ All done! Matchmaking table is ready."
echo ""
echo "Verify with: aws dynamodb describe-table --table-name $TABLE_NAME --region $REGION"
