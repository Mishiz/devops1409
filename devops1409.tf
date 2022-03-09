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
variable "access_id" {}
variable "secret_key" {}


provider "digitalocean" {
  token = var.do_token
  spaces_access_id  = var.access_id
  spaces_secret_key = var.secret_key

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

  provisioner "file" {
    source = "/root/.s3cfg"
    destination = "/root/.s3cfg"
  }

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
      "apt install -y default-jdk",
      "apt install -y git",
      "apt install -y maven",
      "apt install -y s3cmd",
      "git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git",
      "cd ./boxfuse-sample-java-war-hello",
      "mvn package",
      "s3cmd put /root/boxfuse-sample-java-war-hello/target/hello-1.0.war s3://dev1408s/ROOT.war"
    ]

  }
}

resource "digitalocean_droplet" "prod1408" {
  image    = "ubuntu-20-04-x64"
  name     = "prod1408"
  region   = "fra1"
  size     = "s-1vcpu-2gb-amd"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  provisioner "file" {
    source      = "/root/.s3cfg"
    destination = "/root/.s3cfg"
  }
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
      "apt install -y default-jdk",
      "apt install -y tomcat9",
      "apt install -y s3cmd",
      "rm -rf /var/lib/tomcat9/webapps/*",
      "cd /var/lib/tomcat9/webapps"
      "s3cmd get s3://dev1408s/ROOT.war"
    ]
  }
}




