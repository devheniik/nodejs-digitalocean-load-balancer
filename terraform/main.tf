terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

resource "digitalocean_vpc" "main" {
  name     = "${var.app_name}-vpc"
  region   = var.region
  ip_range = "10.20.0.0/16"
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "${var.app_name}-db"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  private_network_uuid = digitalocean_vpc.main.id
}

resource "digitalocean_database_db" "app_database" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.db_name
}

resource "digitalocean_database_user" "app_user" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.db_user
}

locals {
  user_data = base64encode(templatefile("${path.module}/../scripts/setup-droplet.sh", {
    db_host     = digitalocean_database_cluster.postgres.private_host
    db_port     = digitalocean_database_cluster.postgres.port
    db_user     = digitalocean_database_user.app_user.name
    db_password = digitalocean_database_user.app_user.password
    db_name     = digitalocean_database_db.app_database.name
  }))
}

resource "digitalocean_droplet" "app" {
  count     = 2
  image     = "ubuntu-22-04-x64"
  name      = "${var.app_name}-${count.index + 1}"
  region    = var.region
  size      = var.droplet_size
  vpc_uuid  = digitalocean_vpc.main.id
  ssh_keys  = [digitalocean_ssh_key.default.id]
  user_data = local.user_data

  tags = ["${var.app_name}", "web-server"]
}

resource "digitalocean_database_firewall" "postgres_firewall" {
  cluster_id = digitalocean_database_cluster.postgres.id

  dynamic "rule" {
    for_each = digitalocean_droplet.app
    content {
      type  = "droplet"
      value = rule.value.id
    }
  }
}

resource "digitalocean_loadbalancer" "app_lb" {
  name     = "${var.app_name}-lb"
  type     = "REGIONAL"
  region   = var.region
  vpc_uuid = digitalocean_vpc.main.id
  size     = "lb-small"

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 3000
  }

  healthcheck {
    protocol               = "http"
    port                   = 3000
    path                   = "/health"
    check_interval_seconds = 10
    response_timeout_seconds = 5
    healthy_threshold      = 2
    unhealthy_threshold    = 3
  }

  droplet_ids = digitalocean_droplet.app[*].id

  depends_on = [digitalocean_droplet.app]
}

# Firewall for app droplets
resource "digitalocean_firewall" "app_firewall" {
  name = "${var.app_name}-firewall"

  droplet_ids = digitalocean_droplet.app[*].id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "3000"
    source_addresses = [digitalocean_vpc.main.ip_range]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  depends_on = [digitalocean_vpc.main]
}