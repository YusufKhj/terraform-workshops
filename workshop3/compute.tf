# Jeder Server bekommt in seinem Subnetz eine eigene Netzwerkkarte mit der
# Webserver-Security-Group. Die festen privaten Adressen sind 10.30.1.10 und 10.30.2.10.
resource "aws_network_interface" "web" {
  count           = 2
  subnet_id       = aws_subnet.public[count.index].id
  private_ips     = ["10.30.${count.index + 1}.10"]
  security_groups = [aws_security_group.web.id]
}

# Zwei Ubuntu-Instanzen vom Typ t2.micro verwenden je eine Netzwerkkarte in ihrer Zone.
# Sie starten, sobald die Firewallregeln und die Zuordnungen der Routing-Tabelle bereit
# sind.
resource "aws_instance" "web" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  primary_network_interface {
    network_interface_id = aws_network_interface.web[count.index].id
  }
  depends_on = [aws_vpc_security_group_ingress_rule.http, aws_vpc_security_group_egress_rule.web_all, aws_route_table_association.public]

  # Beim ersten Start führt Ubuntu das Skript als root aus. Bei geändertem Skripttext
  # ersetzt Terraform die Instanz, damit das neue Skript läuft.
  user_data                   = <<-EOF
    #!/bin/bash
    set -e
    # Wenn die Paketquellen beim Start noch nicht erreichbar sind, versucht das Skript den
    # Abruf bis zu 30-mal mit jeweils zehn Sekunden Pause.
    for attempt in $(seq 1 30); do
      if apt-get -o APT::Update::Error-Mode=any update; then
        break
      fi
      sleep 10
    done

    # Apache installieren, starten und für künftige Starts aktivieren. Die Nummer auf der
    # Startseite zeigt, welcher Server die Anfrage beantwortet hat.
    apt-get -o DPkg::Lock::Timeout=180 install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello World</h1><p>Workshop 3 - Server ${count.index + 1}</p>" > /var/www/html/index.html
  EOF
  user_data_replace_on_change = true
  tags                        = { Name = "workshop-3-web${count.index + 1}" }
}

# Sobald die Instanzen und das Gateway bereit sind, ordne ich jeder Netzwerkkarte eine
# Elastic IP zu. Darüber können die Server die Ubuntu-Paketquellen erreichen.
resource "aws_eip" "web" {
  count                     = 2
  domain                    = "vpc"
  network_interface         = aws_network_interface.web[count.index].id
  associate_with_private_ip = aws_network_interface.web[count.index].private_ip
  depends_on                = [aws_internet_gateway.main, aws_instance.web]
}
