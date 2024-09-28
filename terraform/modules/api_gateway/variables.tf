variable "api_name" {
  description = "The name of the API Gateway"
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to integrate with API Gateway"
}

variable "region" {
  description = "The AWS region to deploy the resources"
}
