variable "worker_uuid" {
  type    = string
  default = ""
}

variable "stage_name" {
  type    = string
  default = ""
}

resource "random_string" "current" {
  length  = 5
  special = false
}

locals {
  prefix = "${
    var.stage_name != "" ? var.stage_name : "metalk8s" }-${
    var.worker_uuid != "" ? var.worker_uuid : random_string.current.result
  }"
}
