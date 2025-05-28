output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = digitalocean_loadbalancer.app_lb.ip
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${digitalocean_loadbalancer.app_lb.ip}"
}

output "droplet_ips" {
  description = "IP addresses of app droplets"
  value = {
    for i, droplet in digitalocean_droplet.app :
    droplet.name => {
      public_ip  = droplet.ipv4_address
      private_ip = droplet.ipv4_address_private
    }
  }
}

output "database_connection" {
  description = "Database connection details"
  value = {
    host     = digitalocean_database_cluster.postgres.host
    port     = digitalocean_database_cluster.postgres.port
    database = digitalocean_database_db.app_database.name
    user     = digitalocean_database_user.app_user.name
  }
  sensitive = true
}

output "database_uri" {
  description = "Database connection URI"
  value       = digitalocean_database_cluster.postgres.uri
  sensitive   = true
}