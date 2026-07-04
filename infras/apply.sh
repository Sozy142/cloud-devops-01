#!/bin/bash
set -e

echo "=== Jenkins AWS Apply Script ==="
cd "$(dirname "$0")/terraform"

# Step 1: Provision all infrastructure
if [ -f last_snapshot.txt ]; then
  SNAPSHOT_ID=$(cat last_snapshot.txt)
  terraform apply -var="jenkins_snapshot_id=$SNAPSHOT_ID"
else
  terraform apply
fi

# Step 2: Wait for NAT to register with SSM
echo "Waiting for NAT to register with SSM..."
NAT_INSTANCE_ID=$(terraform output -raw nat_instance_id)

until aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$NAT_INSTANCE_ID" \
  --query 'InstanceInformationList[0].InstanceId' \
  --output text 2>/dev/null | grep -q "$NAT_INSTANCE_ID"; do
  echo "NAT not ready yet, waiting 15 seconds..."
  sleep 15
done
echo "NAT is ready!"

# Step 3: Configure NAT instance
echo "Configuring NAT instance..."
CONTROLLER_ID=$(terraform output -raw controller_instance_id)
cd "../ansible"
ansible-playbook site.yml --limit jenkins_aws_nat_instance

# Step 4: Wait for Controller to register with SSM
echo "Waiting for Controller to register with SSM..."
cd "../terraform"
CONTROLLER_ID=$(terraform output -raw controller_instance_id)
cd "../ansible"

until aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$CONTROLLER_ID" \
  --query 'InstanceInformationList[0].InstanceId' \
  --output text 2>/dev/null | grep -q "$CONTROLLER_ID"; do
  echo "Controller not ready yet, waiting 15 seconds..."
  sleep 15
done
echo "Controller is ready!"

# Step 5: Configure Jenkins Controller
echo "Configuring Jenkins Controller..."
ansible-playbook site.yml --limit jenkins_aws_controller_instance

echo "=== Done! Jenkins is ready ==="