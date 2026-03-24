#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

ansible --version 

sudo chmod +x ~/runner-scripts/job_started.sh
sudo chmod +x ~/runner-scripts/job_completed.sh
sudo chown ubuntu:ubuntu ~/runner-scripts/job_started.sh
sudo chown ubuntu:ubuntu ~/runner-scripts/job_completed.sh

sudo chmod -R +x ~/setup-scripts/

sudo cp ~/setup-scripts/docker_prune.sh /etc/cron.daily/docker_prune.sh
sudo chmod +x /etc/cron.daily/docker_prune.sh

sudo mkdir ~/actions-runner
sudo chown -R ubuntu:ubuntu ~/actions-runner

sudo sh -c "echo ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/ubuntu/runner-scripts/job_started.sh >> /home/ubuntu/actions-runner/.env"
sudo sh -c "echo ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/home/ubuntu/runner-scripts/job_completed.sh >> /home/ubuntu/actions-runner/.env"

