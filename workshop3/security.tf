# Die Security Group bündelt die Netzwerkregeln für den Zugriff auf Apache und für
# ausgehende Verbindungen.
resource "aws_security_group" "web" {
  name_prefix = "workshop-3-web-"
  description = "Workshop web servers"
  vpc_id      = aws_vpc.main.id
}

# Die Server nehmen HTTP auf TCP-Port 80 nur vom Load Balancer an. Seine Security Group
# ist deshalb die erlaubte Quelle.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Der ausgehende IPv4-Verkehr ist auf allen Ports und für alle Protokolle erlaubt. So kann
# Ubuntu die Pakete für Apache herunterladen.
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
