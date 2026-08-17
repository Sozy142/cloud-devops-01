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

# Step 2: Wait for NAT to fully boot and register with SSM
NAT_INSTANCE_ID=$(terraform output -raw nat_instance_id)
CONTROLLER_ID=$(terraform output -raw controller_instance_id)

echo "Waiting for NAT instance status checks to pass..."
aws ec2 wait instance-status-ok --instance-ids "$NAT_INSTANCE_ID"

echo "Waiting for NAT to register with SSM..."
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
cd "../ansible"
ansible-playbook site.yml --limit jenkins_aws_nat_instance

# Step 4: Wait for Controller to fully boot and register with SSM
echo "Waiting for Controller instance status checks to pass..."
aws ec2 wait instance-status-ok --instance-ids "$CONTROLLER_ID"

echo "Waiting for Controller to register with SSM..."
until aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$CONTROLLER_ID" \
  --query 'InstanceInformationList[0].InstanceId' \
  --output text 2>/dev/null | grep -q "$CONTROLLER_ID"; do
  echo "Controller not ready yet, waiting 15 seconds..."
  sleep 15
done
echo "Controller is ready!"
sleep 15

# Step 5: Configure Jenkins Controller
echo "Configuring Jenkins Controller..."
ansible-playbook site.yml --limit jenkins_aws_controller_instance

# Step 6: Fix references that don't survive destroy/apply on their own —
# the ALB gets a brand new DNS name every apply (GitHub still has the old
# one saved), and Jenkins' own config.xml (restored from the data volume
# snapshot) still points at the previous VPC's subnet/security-group IDs,
# which no longer exist once the VPC is rebuilt.
cd "../terraform"

echo "Updating GitHub webhook URLs to new ALB DNS..."
ALB_DNS=$(terraform output -raw alb_dns_name)
while IFS= read -r REPO; do
  # Skip blank lines and comments
  [[ -z "$REPO" || "$REPO" == \#* ]] && continue
  echo "  -> $REPO"
  HOOK_ID=$(gh api "repos/${REPO}/hooks" --jq '.[0].id')
  if [ -z "$HOOK_ID" ] || [ "$HOOK_ID" = "null" ]; then
    echo "     WARNING: no webhook found on $REPO, skipping"
    continue
  fi
  gh api "repos/${REPO}/hooks/${HOOK_ID}" --method PATCH \
    -f "config[url]=http://${ALB_DNS}/github-webhook/" \
    -f "config[content_type]=json" \
    -f "config[insecure_ssl]=0"
  echo "     updated (hook $HOOK_ID) -> http://${ALB_DNS}/github-webhook/"
done < deploy-targets.txt

echo "Patching stale subnet/security-group IDs in Jenkins config.xml..."
NEW_SG=$(terraform output -raw agent_sg_id)
NEW_SUBNET=$(terraform output -raw private_subnet_id)
aws ssm send-command \
  --instance-ids "$CONTROLLER_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters "commands=[
    \"sed -i -E 's#<securityGroups>sg-[a-z0-9]+</securityGroups>#<securityGroups>${NEW_SG}</securityGroups>#' /var/lib/jenkins/config.xml\",
    \"sed -i -E 's#<subnetId>subnet-[a-z0-9]+</subnetId>#<subnetId>${NEW_SUBNET}</subnetId>#' /var/lib/jenkins/config.xml\",
    \"sed -i -E 's#<currentSubnetId>subnet-[a-z0-9]+</currentSubnetId>#<currentSubnetId>${NEW_SUBNET}</currentSubnetId>#' /var/lib/jenkins/config.xml\",
    \"systemctl restart jenkins\"
  ]" \
  --query 'Command.CommandId' --output text
echo "config.xml patched, Jenkins restarting..."

echo ""
echo "NOTE: if the first build after this still fails to get an agent with"
echo "\"Security groups must all be VPC security groups...\", the raw config"
echo "edit above wasn't enough on its own (seen once, root cause not fully"
echo "identified) - open http://localhost:8080 (via an SSM port-forward to"
echo "\$CONTROLLER_ID) -> Manage Jenkins -> Clouds -> ec2-agent-cloud ->"
echo "docker-agent, and click Save once with no changes."

echo "=== Done! Jenkins is ready ==="