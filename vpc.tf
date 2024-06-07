# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "zone" {
  description = "zone"
}

locals {
  subnet_range = {
    default    = "10.10.0.0/24"
    staging    = "10.10.2.0/24"
    production = "10.10.3.0/24"
  }
  net_name = "${terraform.workspace}-${var.project_id}"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${local.net_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.net_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = local.subnet_range[terraform.workspace]
}
