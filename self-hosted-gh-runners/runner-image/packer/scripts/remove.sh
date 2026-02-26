#!/bin/bash

ACCESS_TOKEN=$1
ORG=$2

REMOVE_TOKEN=$(curl -L -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${ACCESS_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/orgs/${ORG}/actions/runners/remove-token \
            | jq .token --raw-output)

cd /home/ubuntu/actions-runner

./config.sh remove --token ${REMOVE_TOKEN}
