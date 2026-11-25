# Nach dem Erstellen zeigt Terraform die Elastic IP an. Damit kann ich die Webseite im Browser
# testen.
output "public_ip" {
  value = aws_eip.web[0].public_ip
}
