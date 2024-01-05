variable "meta" {
  type = object({
    account = string
    project = string
    env     = string
    region  = string
  })
}

variable "kms_key" {
  type    = string
  default = null
}

variable "tls_version" {
  type = string
  default = "1.2"
}

variable "prefix" {
  type = string
}

variable "buckets" {
  type = map(object({
    expiration  = optional(number),
    policy      = optional(string),
    enforce_tls = optional(bool, true),
    versioning  = optional(bool, false)
  }))
}
