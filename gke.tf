# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

locals {
  machine_types = {
    default    = "n1-standard-1"
    staging    = "n1-standard-1"
    production = "n1-standard-2"
  }
  cluster_name = "${terraform.workspace}-${var.project_id}-gke"
  node_version = "1.28.9-gke.1000000"
}

# GKE cluster

resource "google_container_cluster" "primary" {
  name     = local.cluster_name
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
  }
}

# Private Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = local.cluster_name
  location = var.zone
  cluster  = google_container_cluster.primary.name

  version    = local.node_version
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = local.machine_types[terraform.workspace]
    tags         = ["gke-node", local.cluster_name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    disk_size_gb = 50
  }
  network_config {
    enable_private_nodes = true
  }
}

# Public Node Pool

resource "google_container_node_pool" "public_nodes" {
  name     = "${local.cluster_name}-public"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  version    = local.node_version
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = local.machine_types[terraform.workspace]
    tags         = ["gke-node", "${local.cluster_name}-public"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    disk_size_gb = 50
  }
  network_config {
    enable_private_nodes = false
  }
}

# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

data "google_client_config" "current" {}

provider "kubernetes" {
  load_config_file = false

  host     = google_container_cluster.primary.endpoint
  username = var.gke_username
  password = var.gke_password

  client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
  client_key             = google_container_cluster.primary.master_auth.0.client_key
  cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  token                  = data.google_client_config.current.access_token
}
