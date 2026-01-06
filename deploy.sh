#!/bin/bash
# AWS AI Study Game - Deployment Script
# This script builds and deploys the application to AWS S3 + CloudFront

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
STACK_NAME="${STACK_NAME:-aws-ai-study-game}"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AWS AI Study Game - Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check prerequisites
command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is required but not installed.${NC}" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}npm is required but not installed.${NC}" >&2; exit 1; }

# Verify AWS credentials
echo -e "\n${YELLOW}Verifying AWS credentials...${NC}"
aws sts get-caller-identity > /dev/null || { echo -e "${RED}AWS credentials not configured.${NC}" >&2; exit 1; }
echo -e "${GREEN}✓ AWS credentials verified${NC}"

# Install dependencies
echo -e "\n${YELLOW}Installing dependencies...${NC}"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Build the application
echo -e "\n${YELLOW}Building application...${NC}"
npm run build
echo -e "${GREEN}✓ Build complete${NC}"

# Check if stack exists
STACK_EXISTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION 2>/dev/null || true)

if [ -z "$STACK_EXISTS" ]; then
    echo -e "\n${YELLOW}Creating CloudFormation stack...${NC}"
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://infrastructure/cloudformation-template.yaml \
        --region $AWS_REGION \
        --capabilities CAPABILITY_IAM
    
    echo -e "${YELLOW}Waiting for stack creation...${NC}"
    aws cloudformation wait stack-create-complete \
        --stack-name $STACK_NAME \
        --region $AWS_REGION
    echo -e "${GREEN}✓ Stack created${NC}"
else
    echo -e "\n${YELLOW}Updating CloudFormation stack...${NC}"
    aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --template-body file://infrastructure/cloudformation-template.yaml \
        --region $AWS_REGION \
        --capabilities CAPABILITY_IAM 2>/dev/null || echo -e "${YELLOW}No stack updates needed${NC}"
fi

# Get bucket name from stack outputs
echo -e "\n${YELLOW}Getting deployment information...${NC}"
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
    --output text)

WEBSITE_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text)

echo -e "${GREEN}Bucket: ${BUCKET_NAME}${NC}"
echo -e "${GREEN}Distribution ID: ${DISTRIBUTION_ID}${NC}"

# Upload files to S3
echo -e "\n${YELLOW}Uploading files to S3...${NC}"
aws s3 sync dist/ s3://$BUCKET_NAME/ \
    --delete \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude "index.html" \
    --exclude "*.json"

# Upload index.html with no-cache
aws s3 cp dist/index.html s3://$BUCKET_NAME/index.html \
    --cache-control "no-cache, no-store, must-revalidate"

echo -e "${GREEN}✓ Files uploaded${NC}"

# Invalidate CloudFront cache
echo -e "\n${YELLOW}Invalidating CloudFront cache...${NC}"
aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*" > /dev/null
echo -e "${GREEN}✓ Cache invalidation started${NC}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${GREEN}Website URL: ${WEBSITE_URL}${NC}"
echo -e "${YELLOW}Note: It may take a few minutes for changes to propagate globally.${NC}"
