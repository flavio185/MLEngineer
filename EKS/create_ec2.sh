#!/bin/bash

# Set AWS credentials
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY="/c"
export AWS_DEFAULT_REGION="us-east-1"  # Change to your preferred region

# Configure AWS CLI
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION
#
#
# 1. Create a VPC -----------------------------------------------------------------------
# Create a VPC with a subnet and an internet gateway:
#
#
# Create a VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)

# Create a subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --output text)

# Create an internet gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)

# Attach the internet gateway to the VPC
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create a route table
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)

# Create a route to the internet gateway
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# Associate the route table with the subnet
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID

# Enable auto-assign public IP on the subnet
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch

echo "VPC created successfully!"
#
#
# 2. Create a Security Group in the VPC -----------------------------------------------------------------
# Create a security group within the VPC:
#
#
# Create a security group
echo "Creating security group..."

SECURITY_GROUP_NAME="my-security-group"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "My security group" --vpc-id $VPC_ID --query 'GroupId' --output text)

# Allow SSH access
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# Create a key pair
KEY_NAME="my-key-pair"
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > ${KEY_NAME}.pem
chmod 400 ${KEY_NAME}.pem

echo "Security group created successfully!"
#
#
# 3. Launch an EC2 Instance in the VPC --------------------------------------------------------------
# Launch the EC2 instance in the specified VPC and subnet:
#
#
# Launch an EC2 instance
INSTANCE_TYPE="t2.micro"  # Change to your preferred instance type
AMI_ID="ami-06b21ccaeff8cd686"  # Amazon Linux 2 AMI (HVM), SSD Volume Type
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SECURITY_GROUP_ID --subnet-id $SUBNET_ID --query 'Instances[0].InstanceId' --output text)

echo "Launching EC2 instance..."
# Wait for the instance to be in the running state
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "EC2 instance created successfully!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "You can connect to the instance using the following command:"
echo "ssh -i ${KEY_NAME}.pem ec2-user@${PUBLIC_IP}"