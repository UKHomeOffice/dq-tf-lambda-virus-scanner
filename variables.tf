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

variable "virus_scan_bucket" {
  default = "s3-dq-bfid-virus-scan"
}

variable "namespace" {
  default = "test"
}

variable "delete_infected_files" {
  description = "Determines whether infected files should be automatically deleted or not"
  default     = "False"
}

variable "process_original_version_only" {
  description = "Determines whether only original file should be scanned if versioning is enabled"
  default     = "False"
}
