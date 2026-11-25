# Der öffentliche Load Balancer bekommt eine eigene Security Group. Die Webserver
# verwenden diese Gruppe als erlaubte Quelle für HTTP.
resource "aws_security_group" "alb" {
  name_prefix = "workshop-3-alb-"
  description = "Public HTTP entry point"
  vpc_id      = aws_vpc.main.id
}

# Browser dürfen von jeder IPv4-Adresse eine HTTP-Verbindung zu Port 80 des Load Balancers
# aufbauen.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Der Load Balancer darf alle IPv4-Ziele erreichen. Darüber leitet er Anfragen an die
# Webserver weiter und prüft deren Erreichbarkeit.
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Der öffentliche Application Load Balancer nimmt Anfragen über beide Zonen entgegen. Er
# verwendet die eigene Security Group und die zwei Subnetze mit ihrer Internetroute.
resource "aws_lb" "web" {
  name               = "workshop-3-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  depends_on         = [aws_route_table_association.public]
}

# Die Zielgruppe verwendet HTTP auf Port 80. Zur Zustandsprüfung ruft der Load Balancer
# die Startseite auf und erwartet den HTTP-Status 200.
resource "aws_lb_target_group" "web" {
  name     = "workshop-3-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path    = "/"
    matcher = "200"
  }
}

# Ich registriere jede der beiden Instanzen mit ihrer ID und dem Apache-Port 80 in der
# Zielgruppe.
resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Der Listener nimmt HTTP-Anfragen auf Port 80 entgegen und leitet sie an die Zielgruppe
# mit den beiden Webservern weiter.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
