variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable db_disk_image {
  description = "Disk image family for reddit db"
  default     = "reddit-mongodb-base"
}

variable network {
  description = "Network ID"
  default     = "default"
}
