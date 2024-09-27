output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.visitor_counter_lambda.arn
}

output "lambda_role_arn" {
  description = "IAM Role ARN for Lambda"
  value       = aws_iam_role.lambda_role.arn
}
