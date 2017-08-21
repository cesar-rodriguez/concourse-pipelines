variable "var1" {}
variable "var2" {}

provider "random" {
  version = "~> 0.1"
}

resource "random_id" "rand" {
  keepers = {
    keep1 = "${var.var1}"
    keep2 = "${var.var2}"
  }

  byte_length = 8
}

output "random" {
  value = "${random_id.rand.keepers.keep1}"
}
