# Terraform gibt den DNS-Namen des Load Balancers aus. Unter dieser Adresse erreiche ich
# die Webseite unabhängig davon, welcher Server antwortet.
output "load_balancer_dns" {
  value = aws_lb.web.dns_name
}
