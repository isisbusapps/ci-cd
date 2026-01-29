variable "source_image" {
    default = env("BASE_IMAGE_ID")
}

variable "source_image_name" {
    default = env("BASE_IMAGE_NAME")
}

variable "new_image" {
    default = env("IMAGE_NAME")
}

variable "flavor" {
    default = env("FLAVOR_ID")
}

variable "network" {
    default = env("NETWORK_ID")
}