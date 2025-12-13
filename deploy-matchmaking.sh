#!/bin/bash

# Deploy Real-Time Matchmaking Infrastructure
echo "🚀 Deploying Real-Time Matchmaking Infrastructure..."

# Deploy matchmaking infrastructure
aws cloudformation deploy \
  --template-file real-time-matchmaking.yml \
  --stack-name vehicle-guesser-matchmaking \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod

if [ $? -eq 0 ]; then
  echo "✅ Matchmaking infrastructure deployed successfully!"
  
  # Get outputs
  WEBSOCKET_URL=$(aws cloudformation describe-stacks \
    --stack-name vehicle-guesser-matchmaking \
    --query 'Stacks[0].Outputs[?OutputKey==`WebSocketUrl`].OutputValue' \
    --output text)
  
  MATCHMAKING_TABLE=$(aws cloudformation describe-stacks \
    --stack-name vehicle-guesser-matchmaking \
    --query 'Stacks[0].Outputs[?OutputKey==`MatchmakingTableName`].OutputValue' \
    --output text)
  
  CONNECTIONS_TABLE=$(aws cloudformation describe-stacks \
    --stack-name vehicle-guesser-matchmaking \
    --query 'Stacks[0].Outputs[?OutputKey==`ConnectionsTableName`].OutputValue' \
    --output text)
  
  echo "📋 Deployment Details:"
  echo "WebSocket URL: $WEBSOCKET_URL"
  echo "Matchmaking Table: $MATCHMAKING_TABLE"
  echo "Connections Table: $CONNECTIONS_TABLE"
  
  echo ""
  echo "🔧 Next Steps:"
  echo "1. Update your .env file with:"
  echo "   VITE_WEBSOCKET_URL=$WEBSOCKET_URL"
  echo ""
  echo "2. Deploy the WebSocket Lambda function:"
  echo "   cd ../cars-backend"
  echo "   zip websocket-deployment.zip websocket.js"
  echo "   aws lambda update-function-code --function-name vehicle-guesser-websocket-prod --zip-file fileb://websocket-deployment.zip"
  echo ""
  echo "3. Update the main backend Lambda with matchmaking table names"
  
else
  echo "❌ Deployment failed!"
  exit 1
fi