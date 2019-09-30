variable "naming_suffix" {
  default = "apps-test-dq"
}

locals {
  naming_suffix = "${var.pipeline_name}-${var.naming_suffix}"
  path_module   = "${var.path_module != "unset" ? var.path_module : path.module}"
}

variable "path_module" {
  default = "unset"
}
variable "pipeline_name" {
  default = "virus-scan-lambda"
}

variable "virus_definition_bucket" {
  default = "s3-dq-bfid-virus-definitions"
}

variable "namespace" {
  default = "test"
}

