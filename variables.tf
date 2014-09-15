variable "access_key" {}
variable "secret_key" {}
variable "web_staging_ami" {}
variable "worker_staging_ami" {}
variable "web_production_ami" {}
variable "worker_production_ami" {}
variable "region" {
  default = "us-east-1"
}
