#!/bin/bash
echo "Clean GH Action Workspace"
WORK_DIR=/home/ubuntu/actions-runner/_work
sudo chwon -R ubuntu:ubuntu $WORK_DIR
sudo chmod -R u+w $WORK_DIR

find "$WORK_DIR" -mindept 1 -delete 2
echo "Cleaned Workspace