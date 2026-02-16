provider "openstack" {
    cloud = "openstack"
}

data "openstack_images_image_ids_v2" "images" {
    name = var.image_name
    sort = "updated_at"
}

data "openstack_compute_flavor_v2" "l3nano" {
    name = var.flavor_name
}

resource "openstack_compute_instance_v2" "basic" {
    count = var.runner_count
    name = "ua-gh-action-runner-${count.index + 1}"
    image_id = data.openstack_images_image_ids_v2.images.ids[0]
    flavor_id = data.openstack_compute_flavor_v2.l3nano.id
    key_pair = "FASE_CLOUD_DEV"
    security_groups = ["default"]

    metadata = {
        use = "gh-action-runner"
    }

    network {
        name = "Internal"
    }
}

output "vm_ips" {
    value = tomap({
        for name, vm in openstack_compute_instance_v2.basic : name => vm.access_ip_v4
    })
}