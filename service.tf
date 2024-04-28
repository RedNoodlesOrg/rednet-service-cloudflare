terraform {
  cloud {
    organization = "RedNoodles"
    workspaces {
      name = "rednet-services-cloudflared"
    }
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

variable "service_name" {
  type        = string
  description = "Name of service"
}

variable "container_name" {
  type        = string
  description = "Name of container"
}

variable "cloudflared_id" {
  type        = string
  description = "Service Token ID for Cloudflare Access"
}

variable "cloudflared_secret" {
  type        = string
  description = "Service Token Secret for Cloudflare Access"
}

variable "cloudflared_token" {
  description = "Token for Cloudflared Tunnel"
  type        = string
}

provider "docker" {
  host = "ssh://docker_user@deploy.rednoodles.bid"
  ssh_opts = [
    "-o", "IdentityAgent=none",
    "-o", "IdentityFile=~/.ssh/id_ed25519",
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-o", "ProxyCommand=/usr/local/bin/cloudflared access ssh --id ${var.cloudflared_id} --secret ${var.cloudflared_secret} --hostname %h"
  ]
}

resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:latest"
}

resource "docker_container" "cloudflared" {
  image    = docker_image.cloudflared.image_id
  name     = "${var.service_name}-${var.container_name}"
  hostname = "${var.service_name}-${var.container_name}"
  command  = ["tunnel", "--no-autoupdate", "run", "--token", var.cloudflared_token]

  networks_advanced {
    name = "erebos-net"
  }

  restart = "unless-stopped"
}


