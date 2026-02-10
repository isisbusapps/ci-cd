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

source "openstack" "gh_action_runner" {
    ssh_username = "ubuntu"
    cloud = "openstack"
    source_image = var.source_image
    flavor = var.flavor
    networks = [var.network]
    image_name = var.new_image
    image_visibility = "private"
    metadata = {
        built_by = "packer"
        base = var.source_image_name
        team = "ua-ci-cd"
        usage = "Self Hosted GH Action Runners"
    }
}

build {
    name = "openstack-image-build"
    sources = ["source.openstack.gh_action_runner"]

    provisioner "file" {
        source = "scripts/configure.sh"
        destination = "~/configure.sh"
    }

    provisioner "shell" {
        script = "scripts/install_ansible.sh"
    }

    provisioner "ansible-local" {
        playbook_file = "playbooks/install_dependencies.yaml"
        extra_arguments = ["--extra-vars", "RUNNER_VERSION=${var.runner_version}"]
    }  
}