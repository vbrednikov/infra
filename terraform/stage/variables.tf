variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable app_disk_image {
  description = "Disk image family for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image family for reddit db"
  default     = "reddit-mongodb-base"
}

variable source_ranges {
  description = "Networks allowed to connect to ssh"
}

variable network {
  description = "Network ID"
  default     = "default"
}
