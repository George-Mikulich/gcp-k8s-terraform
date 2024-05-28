# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

resource "google_compute_instance" "vpn-server" {
  boot_disk {
    auto_delete = true
    device_name = "vpn-server"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20240515"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  machine_type = "e2-medium"
  name         = "vpn-server"

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = google_compute_subnetwork.subnet.name
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  tags = ["http-server", "https-server", "vpn-server-network"]
  zone = "europe-central2-c"

  metadata_startup_script = "sudo apt update; sudo apt upgrade; curl -o debian-11-vpn-server.sh https://raw.githubusercontent.com/Angristan/openvpn-install/master/openvpn-install.sh; chmod -v +x debian-11-vpn-server.sh"
}
