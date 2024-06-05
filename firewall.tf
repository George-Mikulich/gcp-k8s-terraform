resource "google_compute_firewall" "ssh-rule" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp-rule" {
  name    = "allow-icmp-cluster"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tcp-rule" {
  name    = "allow-tcp-cluster"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp-rule2" {
  name    = "allow-icmp-vpn"
  network = google_compute_network.vpc-vpn.name
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tcp-rule2" {
  name    = "allow-tcp-vpn"
  network = google_compute_network.vpc-vpn.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}