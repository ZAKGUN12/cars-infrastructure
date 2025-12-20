#!/bin/bash

# Vehicle Guesser Infrastructure Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
STACK_PREFIX="vehicle-guesser"
REGION="eu-west-1"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure'."
    exit 1
fi

# Deploy Cognito stack
deploy_cognito() {
    print_status "Deploying Cognito stack..."
    
    aws cloudformation deploy \
        --template-file templates/cognito-simple.yml \
        --stack-name "${STACK_PREFIX}-cognito" \
        --capabilities CAPABILITY_IAM \
        --region $REGION \
        --parameter-overrides \
            EnableGoogleAuth=true \
            GoogleOAuthSecretName=vehicle-guesser-google-oauth-prod-jR3mey
    
    print_status "Cognito stack deployed successfully"
}

# Deploy backend stack
deploy_backend() {
    print_status "Deploying backend stack..."
    
    # Get Cognito User Pool ID from the cognito stack
    USER_POOL_ID=$(aws cloudformation describe-stacks \
        --stack-name "${STACK_PREFIX}-cognito" \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
        --output text)
    
    if [ -z "$USER_POOL_ID" ]; then
        print_error "Could not retrieve User Pool ID from Cognito stack"
        exit 1
    fi
    
    aws cloudformation deploy \
        --template-file templates/backend-updated.yml \
        --stack-name "${STACK_PREFIX}-backend" \
        --capabilities CAPABILITY_IAM \
        --region $REGION \
        --parameter-overrides UserPoolId=$USER_POOL_ID
    
    print_status "Backend stack deployed successfully"
}

# Main deployment function
main() {
    print_status "Starting Vehicle Guesser infrastructure deployment..."
    
    case "${1:-all}" in
        "cognito")
            deploy_cognito
            ;;
        "backend")
            deploy_backend
            ;;
        "all")
            deploy_cognito
            deploy_backend
            ;;
        *)
            print_error "Usage: $0 [cognito|backend|all]"
            exit 1
            ;;
    esac
    
    print_status "Deployment completed successfully!"
}

main "$@"