resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket   = "${var.prefix}-${each.key}"
  tags     = local.module_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key
      sse_algorithm     = var.kms_key != null ? "aws:kms" : "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.buckets : k => v if lookup(v, "versioning", false) }
  bucket   = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    id     = "cleanup delete markers"
    status = "Enabled"

    expiration {
      expired_object_delete_marker = true
    }
  }

  rule {
    id     = "delete old versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = 7
      newer_noncurrent_versions = 2
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  dynamic "rule" {
    for_each = each.value.expiration != null ? [each.value.expiration] : []
    content {
      id     = "delete old objects"
      status = "Enabled"

      expiration {
        days = rule.value
      }
    }
  }
}

data "aws_iam_policy_document" "s3_enforce_tls" {
  for_each = var.buckets

  statement {
    actions = [
      "s3:*",
    ]

    effect = "Deny"
    resources = [ "${aws_s3_bucket.this[each.key].arn}/*" ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [ var.tls_version ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]

    effect = "Deny"
    resources = [ "${aws_s3_bucket.this[each.key].arn}/*" ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test = "Bool"
      variable = "aws:SecureTransport"
      values = [ "false" ]
    }
  }
}

data "aws_iam_policy_document" "bucket_policies" {
  for_each = { for k, v in var.buckets : k => v if v.policy != null || v.enforce_tls }
  source_policy_documents = [
    each.value.policy != null ? each.value.policy : "",
    each.value.enforce_tls ? data.aws_iam_policy_document.s3_enforce_tls[each.key].json : "",
  ]
}

resource "aws_s3_bucket_policy" "policies" {
  # for_each = { for k, v in var.buckets : k => v.policy if v.policy != null }
  for_each = { for k, v in data.aws_iam_policy_document.bucket_policies : k => v.json }
  bucket   = aws_s3_bucket.this[each.key].id

  policy = "${each.value}"
}
