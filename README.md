# Vehicle Guesser Infrastructure

AWS CloudFormation templates for Vehicle Guesser infrastructure.

## Components
- **cognito-simple.yml**: User authentication
- **complete-backend.yml**: API Gateway, Lambda, DynamoDB
- **cloudfront-security.json**: CDN configuration

## Deployment Order
1. Deploy Cognito stack
2. Deploy backend stack with Cognito outputs
3. Deploy frontend with environment variables

## Manual Deployment
```bash
# Deploy Cognito
aws cloudformation deploy \
  --template-file cognito-simple.yml \
  --stack-name vehicle-guesser-cognito \
  --capabilities CAPABILITY_IAM

# Deploy Backend
aws cloudformation deploy \
  --template-file complete-backend.yml \
  --stack-name vehicle-guesser-backend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides UserPoolId=<COGNITO_POOL_ID>
```# Updated with Google OAuth secrets
