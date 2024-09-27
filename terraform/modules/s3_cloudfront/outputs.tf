output "cloudfront_distribution_id" {
  description = "The id of the cloudfront distribution"
  value = aws_cloudfront_distribution.website_distribution.id
}