# Ich starte eine t2.micro mit Ubuntu im ersten der sortierten Standard-Subnetze. Sie
# bekommt eine öffentliche IPv4-Adresse und die Security Group, sobald deren Regeln bereit
# sind.
resource "aws_instance" "web" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web.id]
  depends_on                  = [aws_vpc_security_group_ingress_rule.http, aws_vpc_security_group_egress_rule.web_all]

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

    # Apache installieren, starten und für künftige Starts aktivieren. Die Startseite
    # zeigt Hello World.
    apt-get -o DPkg::Lock::Timeout=180 install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello World</h1><p>Workshop 1</p>" > /var/www/html/index.html
  EOF
  user_data_replace_on_change = true
  tags                        = { Name = "workshop-1-web${count.index + 1}" }
}
