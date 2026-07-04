#!/bin/bash
set -e

echo "=== Jenkins AWS Destroy Script ==="
cd "$(dirname "$0")/terraform"
VOLUME_ID=$(terraform output -raw jenkins_ebs_volume_id)
echo "EBS Volume ID: $VOLUME_ID"
#delete the last snapshot if it exists
if [ -f last_snapshot.txt ]; then
  OLD_SNAPSHOT=$(cat last_snapshot.txt)
  echo "Deleting old snapshot: $OLD_SNAPSHOT"
  aws ec2 delete-snapshot --snapshot-id $OLD_SNAPSHOT
  echo "Old snapshot deleted"
fi

#create a new snapshot of the EBS volume
echo "Creating snapshot..."
SNAPSHOT_ID=$(aws ec2 create-snapshot \
  --volume-id $VOLUME_ID \
  --description "jenkins-aws-backup-$(date +%Y%m%d)" \
  --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=jenkins-aws-backup},{Key=Project,Value=jenkins-aws}]" \
  --query 'SnapshotId' \
  --output text)

echo "Snapshot created: $SNAPSHOT_ID"
#wait for the snapshot to complete
echo "Waiting for snapshot to complete..."
aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID
echo "Snapshot $SNAPSHOT_ID is now completed."

echo $SNAPSHOT_ID > last_snapshot.txt
echo "Snapshot ID saved to last_snapshot.txt"

echo "Destroying infrastructure..."
terraform destroy