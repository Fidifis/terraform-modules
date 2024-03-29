resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = local.module_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

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
}
