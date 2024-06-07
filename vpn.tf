resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  region  = var.region
  name    = "ha-vpn"
  network = google_compute_network.vpc.id
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "external-gateway"
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "An externally managed VPN gateway"
  interface {
    id         = 0
    ip_address = "34.118.36.183"
  }
}

resource "google_compute_router" "router1" {
  name    = "ha-vpn-router1"
  network = google_compute_network.vpc.name
  bgp {
    asn = 64514
  }
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = "ha-vpn-tunnel1"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = "a secret message"
  router                          = google_compute_router.router1.id
  vpn_gateway_interface           = 0
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                            = "ha-vpn-tunnel2"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = "a secret message"
  router                          = " ${google_compute_router.router1.id}"
  vpn_gateway_interface           = 1
}

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.router1.name
  region     = var.region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "router1_peer1" {
  name                      = "router1-peer1"
  router                    = google_compute_router.router1.name
  region                    = var.region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface1.name
}

resource "google_compute_router_interface" "router1_interface2" {
  name       = "router1-interface2"
  router     = google_compute_router.router1.name
  region     = var.region
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "router1_peer2" {
  name                      = "router1-peer2"
  router                    = google_compute_router.router1.name
  region                    = var.region
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface2.name
}

# VPN VPC
resource "google_compute_network" "vpc-vpn" {
  name                    = "vpn-server-vpc"
  auto_create_subnetworks = "false"
}

# VPN Subnet
resource "google_compute_subnetwork" "vpn-subnet" {
  name          = "vpn-server-vpc-subnet"
  region        = var.region
  network       = google_compute_network.vpc-vpn.name
  ip_cidr_range = "10.10.1.0/24"
}

resource "google_compute_instance" "vpn-server" {
  name         = "vpn-server"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["vpn-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  metadata_startup_script = "echo hello"

  network_interface {
    network    = google_compute_network.vpc-vpn.name
    subnetwork = google_compute_subnetwork.vpn-subnet.id
    access_config {
      #nat_ip = "34.118.36.183"
    }
  }
}