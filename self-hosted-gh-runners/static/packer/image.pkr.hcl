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

source "openstack" "gh_action_runner_image" {
    ssh_username = "ubuntu"
    cloud = "openstack"
    source_image = var.source_image
    flavor = var.flavor
    networks = [var.network]
    floating_ip = var.floating_ip
    image_name = var.new_image
    image_visibility = "private"
    metadata = {
        built_by = "packer"
        team = "ua-ci-cd"
        usage = "Self Hosted GH Action Runners"
    }
}

build {
    name = "openstack-image-build"
    sources = ["source.openstack.gh_action_runner_image"]

    provisioner "shell" {
        inline = [ "mkdir ~/setup-scripts && mkdir ~/runner-scripts" ]
    }

    provisioner "file" {
        source = ["../../scripts/setup-scripts/"]
        destination = "~/setup-scripts/"
    }

    provisioner "file" {
        source "../../scripts/runner-scripts/"
        destination = "~/runner-scripts"
    }

    provisioner "shell" {
        script = "../../scripts/packer-scripts/setup_vm.sh"
    }

    provisioner "ansible-local" {
        playbook_file = "../../playbooks/install_dependencies.yaml"
        extra_arguments = ["--extra-vars", "RUNNER_VERSION=${var.runner_version}"]
    }  
}