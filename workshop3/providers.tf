# Ich verwende Terraform ab 1.10 innerhalb der Hauptversion 1 und den AWS-Provider von
# HashiCorp in Version 6.
terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Beim Initialisieren gebe ich den S3-Bucket an. Apply und Destroy verwenden denselben
  # verschlüsselten State. Die Sperrdatei verhindert gleichzeitige Änderungen.
  backend "s3" {
    key          = "workshop3/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

# Mit den Zugangsdaten meiner Academy-Sitzung verwaltet der Provider die Ressourcen in
# Nord-Virginia.
provider "aws" {
  region = "us-east-1"
}

# Terraform sucht das neueste Ubuntu-24.04-Serverimage für x86-64. Die Konto-ID beschränkt
# die Suche auf den Herausgeber Canonical.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
