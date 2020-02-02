terraform {
  required_version = ">= 0.12, < 0.13"
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
#using $DIGITALOCEAN_ACCESS_TOKEN ENV VAR
}

#ssh keys - doctl compute ssh-key list   
data "digitalocean_ssh_key" "dosshkey" {
  name = "terraform"
}

# Create a web server
# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "vpn" {
  image  = "ubuntu-19-10-x64"
  name   = "vpn-wg"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.dosshkey.id]
  ipv6 = true
}

resource "digitalocean_firewall" "vpn-fw" {
  name = "only-22-5555"

  droplet_ids = [digitalocean_droplet.vpn.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "51820"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "51820"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

   inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}