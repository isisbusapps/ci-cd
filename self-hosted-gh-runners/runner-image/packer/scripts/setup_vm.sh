#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

ansible --version 

sudo sh -c "echo ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/ubunutu/scripts/job_started.sh >> /etc/environment"
sudo sh -c "echo ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/home/ubuntu/scripts/job_completed.sh >> /etc/environment"

sudo chmod +x ~/job_started.sh
sudo chmod +x ~/job_completed.sh
sudo chown ubuntu:ubuntu ~/job_started.sh
sudo chown ubuntu:ubuntu ~/job_completed.sh

sudo cp ~/scripts/docker_prune.sh /etc/cron.daily/docker_prune.sh
sudo chmod +x /etc/cron.daily/docker_prune.sh

sudo mkdir ~/actions-runner
sudo chown -R ubuntu:ubuntu ~/actions-runner