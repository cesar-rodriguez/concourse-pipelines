variable "environment" {}

provider "aws" {
  profile = "${var.environment}"
  region  = "us-east-1"
}

data "aws_iam_account_alias" "current" {}

output "account_id" {
  value = "${data.aws_iam_account_alias.current.account_alias}"
}
