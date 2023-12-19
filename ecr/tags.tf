locals {
  module_tags = merge(
    var.tags,
    {
      Module = "ecr"
    })
}
