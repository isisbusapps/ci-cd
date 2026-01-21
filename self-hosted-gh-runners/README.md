# Deployment and Scaling of Self Hosted GitHub Action runners for the Users & Auth Team

Use of GitHub Self Hosted action runners is currently free. However, we don't want to manage them constantly, being able to created & destroy VMs on demand will improve security, performance & allow package and version changes to be made automatically between workflow runs.

## Which Openstack VM should be used?

### GitHub Hosted Runner Resource Usage

1. 1 CPU / 5 GB RAM / 14 GB SSD
2. 4 CPU / 16 GB RAM / 14 GB SSD

### OpenStack Provided VMs

1. `l3.nano` 2 CPU / 8 GB RAM / 50 GB SSD
2. `l3.micro` 4 CPU / 16 GB RAM / 100 GB SSD

A mix of both nano and micro VMs will allow performance to be maintained when running tests or build jobs. The scaler should be set up to know when to request a nano or micro VM.

## How to create & destroy runners

Terraform can be used to create & destroy VMs 
