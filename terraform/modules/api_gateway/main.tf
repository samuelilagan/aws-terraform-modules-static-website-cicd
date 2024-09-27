resource "aws_api_gateway_rest_api" "visitor_counter_api" {
  name        = var.api_name
  description = "API Gateway for visitor counter Lambda"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
  path_part   = var.api_resource_path
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.visitor_counter_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  stage_name  = var.stage_name
}
