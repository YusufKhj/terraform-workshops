# Für die Netzwerkkarte des Webservers lege ich in meiner VPC eine eigene Security Group an.
resource "aws_security_group" "web" {
  name_prefix = "workshop-2-web-"
  description = "Workshop web servers"
  vpc_id      = aws_vpc.main.id
}

# Browser dürfen von jeder IPv4-Adresse eine TCP-Verbindung zu Port 80 aufbauen, um die
# Apache-Seite per HTTP zu laden.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Der Server darf über alle Protokolle und Ports beliebige IPv4-Ziele erreichen. Das braucht
# er etwa zum Herunterladen von Apache.
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
