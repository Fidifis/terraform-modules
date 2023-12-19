variable "meta" {
  type = object({
    account = string
    project = string
    env     = string
    region  = string
  })
}

variable "tags"{
  type = map(string)
  default = {}
}

variable "default_config" {
  type = object({
    immutable = optional(bool, true)
    scan = optional(bool, true)
    lifecycle = optional(list(object({
      tagStatus = optional(string, "any")
      tagPrefixList = optional(list(string))
      type = string
      count = number
    })))
  })
}

variable "repositories" {
  type = map(object({
    immutable = optional(bool)
    scan = optional(bool)
    lifecycle = optional(list(object({
      tagStatus = optional(string, "any")
      tagPrefixList = optional(list(string))
      type = string
      count = number
    })))
  }))
}
