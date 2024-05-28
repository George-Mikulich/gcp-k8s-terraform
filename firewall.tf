resource "google_compute_firewall" "ssh-rule" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["34.0.243.91/32"]
}

resource "google_compute_firewall" "vpn-rule" {
  name    = "allow-vpn"
  network = google_compute_network.vpc.name
  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
  source_ranges = ["0.0.0.0/0"]
  source_tags   = ["vpn-server-network"]
}