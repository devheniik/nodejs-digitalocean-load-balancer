variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of SSH key in DigitalOcean"
  type        = string
  default     = "terraform-key"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/key.pub"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Size of droplets"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "nodejs-loadbalancer-demo"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "demouser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "demo123!@#"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "loadbalancer_demo"
}