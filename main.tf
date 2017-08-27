variable "environment" {}

provider "aws" {
  profile = "${var.environment}"
}

data "aws_iam_account_alias" "current" {}

output "account_id" {
  value = "${data.aws_iam_account_alias.current.account_alias}"
}
