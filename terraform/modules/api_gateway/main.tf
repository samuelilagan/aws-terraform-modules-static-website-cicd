resource "aws_api_gateway_rest_api" "visitor_counter_api" {
  name        = var.api_name
  description = "API for Visitor Counter"
}

resource "aws_api_gateway_resource" "counter_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
  path_part   = "counter"
}

resource "aws_api_gateway_method" "counter_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.counter_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"  
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = split(":", var.lambda_function_arn)[6]  # Extract the function name from the ARN
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.api_deployment.execution_arn}/*"  
}

# Enable CORS
resource "aws_api_gateway_method_response" "cors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_method.http_method
  status_code = aws_api_gateway_method_response.cors_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
