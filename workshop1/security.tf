# Die Security Group bündelt die Netzwerkregeln für den Zugriff auf Apache und für
# ausgehende Verbindungen.
resource "aws_security_group" "web" {
  name_prefix = "workshop-1-web-"
  description = "Workshop web servers"
  vpc_id      = data.aws_vpc.default.id
}

# Browser dürfen von jeder IPv4-Adresse per HTTP auf den Webserver zugreifen. Dafür öffne
# ich TCP-Port 80.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Der ausgehende IPv4-Verkehr ist auf allen Ports und für alle Protokolle erlaubt. So kann
# Ubuntu die Pakete für Apache herunterladen.
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
