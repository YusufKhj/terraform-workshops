# Ich lese die vorhandene Standard-VPC aus, damit der Webserver dieses Netzwerk verwenden
# kann.
data "aws_vpc" "default" {
  default = true
}

# Die Filter wählen die Standard-Subnetze der Availability Zones in dieser VPC aus. In
# einem davon startet später der Webserver.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
