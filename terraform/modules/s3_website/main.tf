resource "aws_s3_bucket" "website_bucket" {
  bucket = var.website_bucket
  force_destroy = var.force_destroy 

  tags = {
    Name = "Website bucket for ${var.website_bucket}"
  }
}

resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website_bucket.id

  versioning_configuration {
    status = var.versioning_enabled
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = var.index_document
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket_allow_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  /* block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
  */
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

/* resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = ["${aws_s3_bucket.website_bucket.arn}/*"],
        Principal = "*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website_bucket_allow_public_access]
}*/
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = ["${aws_s3_bucket.website_bucket.arn}/*"],
        Principal = "*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website_bucket_allow_public_access]
}