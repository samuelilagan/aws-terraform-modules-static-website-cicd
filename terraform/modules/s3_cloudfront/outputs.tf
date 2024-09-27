output "cloudfront_distribution_id" {
  description = "The id of the cloudfront distribution"
  value = aws_cloudfront_distribution.website_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "Used for the OAC for the s3 bucket policy"
  value = aws_cloudfront_distribution.website_distribution.arn
}