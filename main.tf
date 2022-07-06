terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# create microservice instance 
resource "aws_instance" "microservice_instance" {
  ami               = "${lookup(var.aws_ami_microservice_instance, var.aws_region)}"
  instance_type     = "${var.aws_instance_type}"
  subnet_id         = "${lookup(var.subnet_id, var.aws_region)}"

  tags = {
    Name = "${var.env}_microservice_instance"
    Environment = "${lookup(var.env, var.aws_region)}"
  }

 # Copy the prometheus node exporter service file  file to instance
  provisioner "file" {
    source      = "./node_exporter.service.tpl"
    destination = "/etc/systemd/system/node_exporter.service"
  }

  # Install prometheus node exporter
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz",
      "tar xvf node_exporter-1.3.1.linux-amd64.tar.gz",
      "cd node_exporter-1.3.1.linux-amd64",
      "sudo cp node_exporter /usr/local/bin",
      "sudo useradd --no-create-home --shell /bin/false node_exporter",
      "sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter",
      "sudo systemctl daemon-reload",
      "sudo systemctl start node_exporter",
      "sudo ufw allow 9100",
      "sudo iptables -I INPUT -p tcp -m tcp --dport 9100 -j ACCEPT"
    
    ]
  }

}


data "template_file" "prometheus_config" {
template = "${file("prometheus.tpl")}"
  vars ={
  addr = aws_instance.microservice_instance.private_ip
  }
}


resource "local_file" "prometheus_config" {
  filename = "prometheus.yaml"
  content  = data.template_file.prometheus_config.rendered
}


resource "aws_instance" "prometheus_instance" {
  ami               = "${lookup(var.aws_ami_base_lunux, var.aws_region)}"
  instance_type     = "${var.aws_instance_type}"
  subnet_id         = "${lookup(var.subnet_id, var.aws_region)}"

  tags = {
    Name = "${var.env}_prometheus_instance"
    Environment = "${lookup(var.env, var.aws_region)}"
  }

  # Copy the prometheus file to instance
  provisioner "file" {
    source      = "./prometheus.yaml"
    destination = "/tmp/prometheus.yml"
  }


  # Copy the prometheus service file  file to instance
  provisioner "file" {
    source      = "./prometheus.service.tpl"
    destination = "/etc/systemd/system/prometheus.service"
  }


  # Install prometheus in the ubuntu
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "cd /tmp",
      "curl -LO https://github.com/prometheus/prometheus/releases/download/v2.32.1/prometheus-2.32.1.linux-amd64.tar.gz",
      "sudo useradd --no-create-home --shell /bin/false prometheus",
      "tar -xzf prometheus-2.32.1.linux-amd64.tar.gz",
      "sudo mv prometheus-2.32.1.linux-amd64/prometheus /usr/local/bin/",
      "sudo mv prometheus-2.32.1.linux-amd64/promtool /usr/local/bin/",
      "sudo chown prometheus:prometheus /usr/local/bin/prometheus",
      "sudo chown prometheus:prometheus /usr/local/bin/promtool",
      "sudo mkdir /etc/prometheus",
      "sudo mkdir /var/lib/prometheus",
      "sudo chown prometheus:prometheus /etc/prometheus",
      "sudo chown prometheus:prometheus /var/lib/prometheus",
      "sudo mv prometheus-2.32.1.linux-amd64/consoles /etc/prometheus",
      "sudo mv prometheus-2.32.1.linux-amd64/console_libraries /etc/prometheus",
      "sudo chown -R prometheus:prometheus /etc/prometheus",
      "sudo cp /tmp/prometheus.yml /etc/prometheus/.",
      "sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml",
      "sudo systemctl daemon-reload",
      "sudo systemctl start prometheus"
    ]
  }  
}





