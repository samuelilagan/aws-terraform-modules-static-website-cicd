output "api_url" {
  description = "URL of the deployed API"
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
}
