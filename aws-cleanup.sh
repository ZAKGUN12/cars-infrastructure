#!/bin/bash

# AWS Infrastructure Cleanup Script
# Removes failed CloudFormation stacks and unused DynamoDB tables

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REGION="eu-west-1"

echo "🧹 AWS Infrastructure Cleanup"
echo "=============================="
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: This will delete failed stacks and unused resources${NC}"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🗑️  Deleting Failed CloudFormation Stacks..."
echo ""

# Delete failed stacks
FAILED_STACKS=(
    "vehicle-guesser-backend"
    "vehicle-guesser-matchmaking"
    "vehicle-guesser-monitoring"
    "vehicle-guesser-missing-tables"
    "vehicle-guesser-backend-working"
    "vehicle-guesser-backend-v2"
)

for stack in "${FAILED_STACKS[@]}"; do
    STATUS=$(aws cloudformation describe-stacks \
        --stack-name "$stack" \
        --region $REGION \
        --query 'Stacks[0].StackStatus' \
        --output text 2>/dev/null || echo "NOT_FOUND")
    
    if [ "$STATUS" != "NOT_FOUND" ]; then
        echo -e "${YELLOW}Deleting stack: $stack (Status: $STATUS)${NC}"
        aws cloudformation delete-stack \
            --stack-name "$stack" \
            --region $REGION
        echo -e "${GREEN}✅ Deletion initiated for $stack${NC}"
    else
        echo -e "⏭️  Stack $stack not found (already deleted)"
    fi
done

echo ""
echo "🗑️  Deleting Unused DynamoDB Tables..."
echo ""

# Delete unused tables
UNUSED_TABLES=(
    "vehicle-guesser-matchmaking-simple"
    "vehicle-guesser-rival-tables-matchmaking"
    "vehicle-guesser-rival-tables-rival-stats"
    "vehicle-guesser-rival-tables-tournaments"
)

for table in "${UNUSED_TABLES[@]}"; do
    if aws dynamodb describe-table \
        --table-name "$table" \
        --region $REGION &> /dev/null; then
        echo -e "${YELLOW}Deleting table: $table${NC}"
        aws dynamodb delete-table \
            --table-name "$table" \
            --region $REGION
        echo -e "${GREEN}✅ Deletion initiated for $table${NC}"
    else
        echo -e "⏭️  Table $table not found (already deleted)"
    fi
done

echo ""
echo -e "${GREEN}✅ Cleanup initiated!${NC}"
echo ""
echo "Note: Stack and table deletions may take a few minutes to complete."
echo "Run 'aws cloudformation list-stacks' to check stack deletion status."
echo "Run 'aws dynamodb list-tables' to check table deletion status."
