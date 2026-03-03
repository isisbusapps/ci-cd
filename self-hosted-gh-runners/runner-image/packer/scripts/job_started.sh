#!/bin/bash
echo "Update Permissions in GH Action Workspace"
WORK_DIR=/home/ubuntu/actions-runner/_work
sudo chown -R ubuntu:ubuntu $WORK_DIR
sudo chmod -R u+rwX $WORK_DIR

echo "Updated Permissions in GH Action Workspace"