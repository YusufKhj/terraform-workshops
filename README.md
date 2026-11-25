# Terraform Workshops

In diesen drei Workshops erstelle ich mit Terraform eine AWS-Infrastruktur und erweitere sie Schritt für Schritt. Als Webserver verwende ich Ubuntu und Apache. Die Webseite zeigt „Hello World“ an.

GitHub-Repository: https://github.com/YusufKhj/terraform-workshops.git

## Die Workshops

Workshop 1: Eine EC2-Instanz in der Standard-VPC. Der öffentliche DNS-Name wird ausgegeben.
Workshop 2: Eine eigene VPC mit Subnetz, Internet-Gateway, Routing-Tabelle, Security Group und Elastic IP für den Webserver.
Workshop 3: Zwei Webserver in verschiedenen Availability Zones und ein Application Load Balancer, der die Anfragen an die Server weiterleitet. Der DNS-Name des Load Balancers wird ausgegeben.

Jeder Workshop liegt in einem eigenen Ordner. Die Infrastruktur von Workshop 3 baut auf dem Aufbau von Workshop 2 auf und wird als eigener Terraform-Stand verwaltet.

## Terraform und GitHub Actions

Die Konfigurationen verwenden den AWS-Provider in der Region `us-east-1`. Die Zugangsdaten stammen aus dem laufenden AWS-Academy-Lab. Workshop 1 und 2 speichern den Terraform-State lokal. Workshop 3 verwendet einen S3-Bucket als gemeinsames Backend.

Für Workshop 3 gibt es zwei manuell startbare GitHub-Workflows. Terraform Apply erstellt oder aktualisiert die Infrastruktur. Terraform Destroy löscht die von Workshop 3 verwalteten Ressourcen. Beide Workflows greifen auf denselben State zu.

Damit die Workflows funktionieren, müssen im Repository die Secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` und `AWS_SESSION_TOKEN` sowie die Variable `TF_STATE_BUCKET` hinterlegt sein. Die Academy-Zugangsdaten sind zeitlich begrenzt und müssen nach Ablauf erneuert werden.

## Why do we need Terraform Cloud (or another backend) when we use CI/CD?

Terraform muss sich merken, welche Ressourcen es bereits erstellt hat. Diese Informationen stehen im Terraform-State. Bei GitHub Actions läuft jeder Workflow auf einem neuen Runner. Deshalb kann ein späterer Workflow nicht automatisch auf eine lokale State-Datei des vorherigen Laufs zugreifen.

Mit einem gemeinsamen Backend können sowohl mein Computer als auch die GitHub-Workflows denselben State verwenden. In diesem Projekt liegt er in einem S3-Bucket. So kann der Destroy-Workflow die Ressourcen finden, die zuvor erstellt wurden. Die Sperrdatei verhindert außerdem, dass zwei Läufe den State gleichzeitig verändern. Terraform Cloud wäre eine andere Möglichkeit, den State gemeinsam zu speichern.

## Projektstruktur

`workshop1/`, `workshop2/` und `workshop3/` enthalten die jeweiligen Terraform-Dateien. In `.github/workflows/` liegen die beiden manuellen GitHub-Workflows. Der Ordner `nachweise/` ist für Screenshots und PDF-Berichte vorgesehen.
