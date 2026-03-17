packer {
    required_plugins {
        openstack = {
            version = "~> 1"
            source = "github.com/hashicorp/openstack"
        }
        ansible = {
            version = "~> 1.1.4"
            source  = "github.com/hashicorp/ansible"
        }
    }
}

source "openstack" "ua-ansible-image" {
    ssh_username = "ubuntu"
    cloud = "openstack"
    source_image = var.source_image
    flavor = var.flavor
    networks = [var.network]
    floating_ip = var.floating_ip
    image_name = "ua-ansible-image"
    image_visibility = "private"
    metadata = {
        built_by = "packer"
        team = "ua-ci-cd"
        usage = "Run Ansible from GH Actions"
    }
}

build {
    name = "Build Ansible Image"
    sources = ["source.openstack.ua-ansible-image"]

    provisioner "shell" {
        script = "../../scripts/packer-scripts/setup_ansible_vm.sh"
    }
}