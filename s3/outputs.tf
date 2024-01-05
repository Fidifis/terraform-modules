output "buckets" {
  value = {
    for s3_name, s3 in var.buckets: s3_name => {
      name = aws_s3_bucket.this[s3_name].id
      arn = aws_s3_bucket.this[s3_name].arn,
      bucket_regional_domain_name = aws_s3_bucket.this[s3_name].bucket_regional_domain_name
    }
  }
}
