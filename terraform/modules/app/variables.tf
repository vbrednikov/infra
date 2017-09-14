variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image family for reddit app"
  default     = "reddit-app-base"
}

variable network {
  description = "Network ID"
  default     = "default"
}
