# Hier lege ich die passenden Versionen fest: Terraform ab 1.10 innerhalb der Version 1 und
# den AWS-Provider von HashiCorp in Version 6.
terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Der Provider verwendet die Zugangsdaten meiner Academy-Sitzung und legt die Ressourcen in
# Nord-Virginia an.
provider "aws" {
  region = "us-east-1"
}

# Ich suche das neueste Ubuntu-24.04-Serverimage für x86-64. Die Konto-ID beschränkt die Suche
# auf Images von Canonical.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
