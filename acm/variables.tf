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

variable "domains" {
  type = set(string)
}
