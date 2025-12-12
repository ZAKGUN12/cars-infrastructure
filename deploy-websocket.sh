#!/bin/bash

# Deploy missing tables first
aws cloudformation deploy \
  --template-file challenge-table.yml \
  --stack-name vehicle-guesser-missing-tables \
  --capabilities CAPABILITY_IAM

# Deploy WebSocket API
aws cloudformation deploy \
  --template-file websocket-api.yml \
  --stack-name vehicle-guesser-websocket \
  --capabilities CAPABILITY_IAM

echo "Infrastructure deployed!"
echo "Get WebSocket URL:"
aws cloudformation describe-stacks --stack-name vehicle-guesser-websocket --query 'Stacks[0].Outputs[?OutputKey==`WebSocketUrl`].OutputValue' --output text