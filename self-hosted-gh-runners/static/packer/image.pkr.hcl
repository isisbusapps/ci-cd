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
    source_image = env("BASE_IMAGE_ID")
    flavor = env("FLAVOR_ID")
    networks = [env("NETWORK_ID")]
    image_name = env("IMAGE_NAME")
    image_visibility = "private"
    metadata = {
        built_by = "packer"
        base =env("BASE_IMAGE_NAME")
    }
}

build {
    name = "openstack-image-build"
    sources = ["source.openstack.gh_action_runner"]

    provisioner "shell" {
        script = "scripts/install_ansible.sh"
    }

    provisioner "ansible-local" {
        playbook_file = "playbooks/install_packages.yaml"
    }
}