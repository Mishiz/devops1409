terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.17.1"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}


provider "digitalocean" {
  token = var.do_token

}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

resource "digitalocean_droplet" "dev1408" {
  image    = "ubuntu-20-04-x64"
  name     = "dev1408"
  region   = "fra1"
  size     = "s-1vcpu-2gb-amd"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y nginx",
      "apt install -y default-jdk",
      "apt install -y git",
      "apt install -y tomcat9",
      "apt install -y maven",
      "git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git",
      "cd ./boxfuse-sample-java-war-hello",
      "mvn package",
      "rm -rf /var/lib/tomcat9/webapps/*",
      "mv /root/boxfuse-sample-java-war-hello/target/hello-1.0.war /var/lib/tomcat9/webapps/ROOT.war"

    ]

  }
}




