# Terraform gibt den öffentlichen DNS-Namen der Instanz aus, damit ich die Apache-Seite im
# Browser testen kann.
output "public_dns" {
  value = aws_instance.web[0].public_dns
}
