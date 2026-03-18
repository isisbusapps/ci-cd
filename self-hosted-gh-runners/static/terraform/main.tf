provider "openstack" {
    cloud = "openstack"
}

data "openstack_images_image_ids_v2" "runner_image" {
    name = "static-gh-action-runner-image"
    sort = "updated_at"
}

data "openstack_images_image_ids_v2" "ansible_image" {
    name = "ua-ansible-image"
    sort = "updated_at"
}

data "openstack_compute_flavor_v2" "l3nano" {
    name = var.flavor_name
}

data "openstack_networking_floatingip_v2" "fip" {
    address = var.floating_ip
}

resource "openstack_compute_instance_v2" "runner" {
    count = var.runner_count
    name = "TEST-WORKFLOW-DEPLOYMENT-ua-gh-action-runner-${count.index + 1}"
    image_id = data.openstack_images_image_ids_v2.runner_image.ids[0]
    flavor_id = data.openstack_compute_flavor_v2.l3nano.id
    key_pair = "FASE_CLOUD_DEV"
    security_groups = ["default"]

    network {
        name = "Internal"
    }
}

resource "openstack_compute_instance_v2" "configure" {
    count = 1
    name = "ua-ansible-image"
    image_id = data.openstack_images_image_ids_v2.ansible_image.ids[0]
    flavor_id = data.openstack_compute_flavor_v2.l3nano.id
    key_pair = "FASE_CLOUD_DEV"
    security_groups = ["default"]

    network {
        name = "ua-ci-cd"
    }
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
    floating_ip = data.openstack_networking_floatingip_v2.fip.address
    instance_id = openstack_compute_instance_v2.configure.id
}

output "vm_ips" {
    value = tomap({
        for name, vm in openstack_compute_instance_v2.runner : name => vm.access_ip_v4
    })
}