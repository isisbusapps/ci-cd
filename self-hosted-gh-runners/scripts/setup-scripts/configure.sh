#!/bin/bash

ACCESS_TOKEN=$1
ORG=$2

echo "Get Reg Token"

REG_TOKEN=$(curl -L -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${ACCESS_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/orgs/${ORG}/actions/runners/registration-token \
            | jq .token --raw-output)

RUNER_NAME=$(hostname)

cd /home/ubuntu/actions-runner
./config.sh --url https://github.com/${ORG} --token ${REG_TOKEN} --name ${RUNNER_NAME} --unattended