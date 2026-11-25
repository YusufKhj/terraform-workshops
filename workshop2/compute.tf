# Meine Netzwerkkarte bekommt im Workshop-Subnetz die feste private Adresse 10.20.1.10. An
# dieser Karte gelten die Regeln der Security Group.
resource "aws_network_interface" "web" {
  count           = 1
  subnet_id       = aws_subnet.public[count.index].id
  private_ips     = ["10.20.${count.index + 1}.10"]
  security_groups = [aws_security_group.web.id]
}

# Ich starte eine t2.micro mit dem gefundenen Ubuntu-Image und meiner Netzwerkkarte. Terraform
# wartet zuvor auf die Firewallregeln und die Zuordnung der Routing-Tabelle.
resource "aws_instance" "web" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  primary_network_interface {
    network_interface_id = aws_network_interface.web[count.index].id
  }
  depends_on = [aws_vpc_security_group_ingress_rule.http, aws_vpc_security_group_egress_rule.web_all, aws_route_table_association.public]

  # Beim ersten Start richtet dieses Skript Apache ein. Ändert sich das Skript,
  # ersetzt Terraform die Instanz, damit es erneut beim Start läuft.
  user_data                   = <<-EOF
    #!/bin/bash
    # Die Elastic IP kommt erst nach dem Start. Bis die Paketquellen erreichbar sind,
    # versucht das Skript den Abruf bis zu 30-mal im Abstand von zehn Sekunden.
    set -e
    for attempt in $(seq 1 30); do
      if apt-get -o APT::Update::Error-Mode=any update; then
        break
      fi
      sleep 10
    done

    # Apache installieren, jetzt und bei künftigen Starts ausführen und die Testseite schreiben.
    apt-get -o DPkg::Lock::Timeout=180 install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello World</h1><p>Workshop 2</p>" > /var/www/html/index.html
  EOF
  user_data_replace_on_change = true

  # Unter diesem Namen finde ich den Server in der EC2-Konsole.
  tags = { Name = "workshop-2-web${count.index + 1}" }
}

# Sobald Gateway und Instanz bereit sind, ordne ich die Elastic IP der privaten Adresse meiner
# Netzwerkkarte zu. So erreicht der Browser den Server unter einer festen öffentlichen
# IPv4-Adresse.
resource "aws_eip" "web" {
  count                     = 1
  domain                    = "vpc"
  network_interface         = aws_network_interface.web[count.index].id
  associate_with_private_ip = aws_network_interface.web[count.index].private_ip
  depends_on                = [aws_internet_gateway.main, aws_instance.web]
}
