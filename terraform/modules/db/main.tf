resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  tags         = ["group-reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network = "${var.network}"

    access_config = {}
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-${var.network}"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
