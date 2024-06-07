resource "google_compute_firewall" "icmp-rule" {
  name    = "${terraform.workspace}-allow-icmp-cluster"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tcp-rule" {
  name    = "${terraform.workspace}-allow-tcp-cluster"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp-rule2" {
  name    = "${terraform.workspace}-allow-icmp-vpn"
  network = google_compute_network.vpc-vpn.name
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tcp-rule2" {
  name    = "${terraform.workspace}-allow-tcp-vpn"
  network = google_compute_network.vpc-vpn.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}