terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

variable "cloudflare_id" {
  type        = string
  description = "Service Token ID for Cloudflare Access"
}

variable "cloudflare_secret" {
  type        = string
  description = "Service Token Secret for Cloudflare Access"
}

variable "cloudflared_token" {
  description = "Token for Cloudflared Tunnel"
  type        = string
}

provider "docker" {
  host     = "ssh://docker_user@deploy.rednoodles.bid"
  ssh_opts = [
    "-o", "IdentityAgent=none" ,
    "-o", "IdentityFile=~/.ssh/id_ed25519",
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-o", "ProxyCommand=/usr/local/bin/cloudflared access ssh --id ${var.cloudflare_id} --secret ${var.cloudflare_secret} --hostname %h"
  ]
}

resource "docker_network" "erebos_net" {
  name = "erebos-net"
}

resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:latest"
}

resource "docker_container" "cloudflared" {
  image   = docker_image.cloudflared.image_id
  name    = "cloudflared"
  command = ["tunnel", "--no-autoupdate", "run", "--token", var.cloudflared_token]

  networks_advanced {
    name = "erebos-net"
  }

  restart = "unless-stopped"
}


