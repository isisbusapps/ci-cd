#!/bin/bash
LOG_FILE=/home/ubuntu/shutdown.log
sudo rm -rf $LOG_FILE
echo Removing Runner >> $LOG_FILE

REMOVE_TOKEN=$(curl -L -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${ACCESS_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/orgs/${ORG}/actions/runners/remove-token \
            | jq .token --raw-output) >> $LOG_FILE

cd /home/ubuntu/FASE/actions-runner

./config.sh remove --token ${REMOVE_TOKEN} --unattended >> $LOG_FILE

echo "Remove Runner" >> $LOG_FILE