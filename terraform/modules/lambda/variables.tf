variable "lambda_function_name" {
  description = "Name of the Lambda function"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
}

variable "api_gateway_invoke_arn" {
  description = "API Gateway invoke ARN to allow Lambda execution"
}
