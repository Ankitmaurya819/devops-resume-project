variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ami_id" {
  default = "ami-0c02fb55956c7d316" # Amazon Linux 2
}
variable "db_user" {}
variable "db_password" {}