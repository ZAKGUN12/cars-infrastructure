# 🏗️ Vehicle Guesser Infrastructure

**AWS CloudFormation templates and deployment scripts**

## Quick Deploy
```bash
./scripts/deploy.sh all
```

## Architecture
- **Cognito**: User authentication with Google OAuth
- **API Gateway**: REST and WebSocket APIs
- **Lambda**: Serverless backend functions
- **DynamoDB**: Game data and user management
- **S3 + CloudFront**: Static asset hosting

## Manual Deployment
```bash
# Deploy Cognito
./scripts/deploy.sh cognito

# Deploy Backend
./scripts/deploy.sh backend
```

## Templates
- `templates/cognito-simple.yml` - User authentication
- `templates/backend-updated.yml` - API Gateway, Lambda, DynamoDB

## Configuration
All configuration is managed through CloudFormation parameters and outputs.

## Related Repositories
- **Frontend**: [cars](../cars) - React + TypeScript + Capacitor
- **Backend**: [cars-backend](../cars-backend) - AWS Lambda functions