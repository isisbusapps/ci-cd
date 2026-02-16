variable "source_image" {
    type = string
    default = env("BASE_IMAGE_ID")
}

variable "source_image_name" {
    type = string
    default = env("BASE_IMAGE_NAME")
}

variable "new_image" {
    type = string
    default = env("IMAGE_NAME")
}

variable "flavor" {
    type = string
    default = env("FLAVOR_ID")
}

variable "network" {
    type = string
    default = env("NETWORK_ID")
}

variable "runner_version" {
    type = string
    default = env("RUNNER_VERSION")
}

variable "floating_ip" {
    type = string
    default = env("FLOATING_IP_ID")
}