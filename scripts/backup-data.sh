#!/bin/bash

# Backup existing DynamoDB data before infrastructure changes

set -e

REGION="eu-west-1"
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

echo "📦 Creating backup directory: $BACKUP_DIR"
mkdir -p $BACKUP_DIR

echo "💾 Backing up GameData table..."
aws dynamodb scan \
    --table-name vehicle-guesser-gamedata-prod \
    --region $REGION \
    --output json > $BACKUP_DIR/gamedata-backup.json

ITEM_COUNT=$(cat $BACKUP_DIR/gamedata-backup.json | jq '.Items | length')
echo "✅ Backed up $ITEM_COUNT items from GameData table"

echo ""
echo "✅ Backup completed successfully!"
echo "📁 Backup location: $BACKUP_DIR"
echo ""
echo "To restore from backup if needed:"
echo "  aws dynamodb batch-write-item --request-items file://$BACKUP_DIR/gamedata-backup.json"
