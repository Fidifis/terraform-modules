locals {
  module_tags = merge(
    var.tags,
    {
      Module = "security-group"
    })
}
