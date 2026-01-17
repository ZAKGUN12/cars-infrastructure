#!/bin/bash

# Verify current infrastructure state

REGION="eu-west-1"

echo "🔍 Checking Infrastructure Status"
echo "=================================="
echo ""

# Check DynamoDB Tables
echo "📊 DynamoDB Tables:"
TABLES=(
    "vehicle-guesser-gamedata-prod"
    "vehicle-guesser-challenges-prod"
    "vehicle-guesser-connections-prod"
    "vehicle-guesser-matchmaking-prod"
)

for table in "${TABLES[@]}"; do
    if aws dynamodb describe-table --table-name $table --region $REGION > /dev/null 2>&1; then
        echo "  ✅ $table"
    else
        echo "  ❌ $table (MISSING)"
    fi
done

echo ""
echo "🔧 Lambda Function:"
if aws lambda get-function --function-name vehicle-guesser-api-prod --region $REGION > /dev/null 2>&1; then
    echo "  ✅ vehicle-guesser-api-prod"
    
    # Check environment variables
    echo ""
    echo "📝 Lambda Environment Variables:"
    aws lambda get-function-configuration \
        --function-name vehicle-guesser-api-prod \
        --region $REGION \
        --query 'Environment.Variables' \
        --output json | jq -r 'to_entries[] | "  \(.key): \(.value)"'
else
    echo "  ❌ vehicle-guesser-api-prod (MISSING)"
fi

echo ""
echo "🌐 API Gateway:"
API_ID=$(aws apigateway get-rest-apis --region $REGION --query 'items[?name==`vehicle-guesser-api-prod`].id' --output text)
if [ -n "$API_ID" ]; then
    echo "  ✅ vehicle-guesser-api-prod (ID: $API_ID)"
    echo "  🔗 URL: https://$API_ID.execute-api.$REGION.amazonaws.com/prod"
else
    echo "  ❌ vehicle-guesser-api-prod (MISSING)"
fi

echo ""
echo "👤 Cognito User Pool:"
if aws cognito-idp describe-user-pool --user-pool-id eu-west-1_kr1QRzuvC --region $REGION > /dev/null 2>&1; then
    echo "  ✅ eu-west-1_kr1QRzuvC"
else
    echo "  ❌ eu-west-1_kr1QRzuvC (MISSING)"
fi

echo ""
echo "=================================="
echo "Summary:"
echo ""

MISSING_COUNT=0
for table in "${TABLES[@]}"; do
    if ! aws dynamodb describe-table --table-name $table --region $REGION > /dev/null 2>&1; then
        ((MISSING_COUNT++))
    fi
done

if [ $MISSING_COUNT -eq 0 ]; then
    echo "✅ All infrastructure components are present"
else
    echo "⚠️  $MISSING_COUNT DynamoDB table(s) missing"
    echo ""
    echo "Run './scripts/safe-update.sh' to create missing tables"
fi
