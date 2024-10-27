#!/bin/bash

# Set AWS credentials
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-east-1"  # Change to your preferred region

# Configure AWS CLI
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION

# 1. Create a new user
USER_NAME="my-everything-user"
aws iam create-user --user-name $USER_NAME

# 2. Create new policies

# EC2 Policy
EC2_POLICY_NAME="EC2FullAccessPolicy"
EC2_POLICY_ARN=$(aws iam create-policy --policy-name $EC2_POLICY_NAME --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeImages",
                "ec2:DescribeKeyPairs",
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "*"
        }
    ]
}' --query 'Policy.Arn' --output text)

# EKS Policy
EKS_POLICY_NAME="EKSFullAccessPolicy"
EKS_POLICY_ARN=$(aws iam create-policy --policy-name $EKS_POLICY_NAME --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "cloudformation:*",
                "ec2:*",
                "iam:CreateRole",
                "iam:PassRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:TagRole",
                "iam:GetRole",
                "eks:*",
                "cloudformation:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}' --query 'Policy.Arn' --output text)

# 3. Attach policies to the user
aws iam attach-user-policy --user-name $USER_NAME --policy-arn $EC2_POLICY_ARN
aws iam attach-user-policy --user-name $USER_NAME --policy-arn $EKS_POLICY_ARN

# 4. Create access key for the user
TEMP_FILE=$(mktemp)
aws iam create-access-key --user-name $USER_NAME --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' --output json > $TEMP_FILE

# Extract Access Key ID and Secret Access Key using awk
ACCESS_KEY_ID=$(awk -F'"' '/AccessKeyId/ {print $4}' $TEMP_FILE)
SECRET_ACCESS_KEY=$(awk -F'"' '/SecretAccessKey/ {print $4}' $TEMP_FILE)

# Clean up the temporary file
rm $TEMP_FILE

echo "User $USER_NAME created and policies attached successfully."
echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"