resource "aws_api_gateway_rest_api" "visitor_counter_api" {
  name        = var.api_name
  description = "API for Visitor Counter"
}

resource "aws_api_gateway_resource" "counter_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
  path_part   = "counter"
}

# Define the POST method for updating the visitor count
resource "aws_api_gateway_method" "post_counter_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id             = aws_api_gateway_resource.counter_resource.id
  http_method             = aws_api_gateway_method.post_counter_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

# Define the GET method to retrieve the visitor count
resource "aws_api_gateway_method" "get_counter_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id             = aws_api_gateway_resource.counter_resource.id
  http_method             = aws_api_gateway_method.get_counter_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"  # Assuming your Lambda function handles POST requests
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_integration.get_lambda_integration]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = split(":", var.lambda_function_arn)[6]  # Extract the function name from the ARN
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.api_deployment.execution_arn}/*"
}

# Enable CORS for OPTIONS method with mock integration
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mock_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id             = aws_api_gateway_resource.counter_resource.id
  http_method             = aws_api_gateway_method.options_method.http_method
  type                    = "MOCK"
}

resource "aws_api_gateway_method_response" "cors_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Methods"    = true
    "method.response.header.Access-Control-Allow-Headers"     = true
  }
}

resource "aws_api_gateway_integration_response" "cors_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.cors_options_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'"  # Or use your specific domain
    "method.response.header.Access-Control-Allow-Methods"    = "'OPTIONS,GET,POST'"  # Allow methods as needed
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"  # Allow headers as needed
  }

  depends_on = [aws_api_gateway_integration.mock_integration]  # Ensure this runs after the mock integration
}

# CORS configuration for the POST method
resource "aws_api_gateway_method_response" "cors_post_counter_method_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.post_counter_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Methods"    = true
    "method.response.header.Access-Control-Allow-Headers"     = true
  }
}

resource "aws_api_gateway_integration_response" "cors_post_counter_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.post_counter_method.http_method
  status_code = aws_api_gateway_method_response.cors_post_counter_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'"
    "method.response.header.Access-Control-Allow-Methods"    = "'OPTIONS,GET,POST'"  # Adjust as needed
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.lambda_integration]  # Ensure this runs after the lambda integration
}

# CORS configuration for the GET method
resource "aws_api_gateway_method_response" "cors_get_counter_method_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.get_counter_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Methods"    = true
    "method.response.header.Access-Control-Allow-Headers"     = true
  }
}

resource "aws_api_gateway_integration_response" "cors_get_counter_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.get_counter_method.http_method
  status_code = aws_api_gateway_method_response.cors_get_counter_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'"
    "method.response.header.Access-Control-Allow-Methods"    = "'OPTIONS,GET,POST'"  # Adjust as needed
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [aws_api_gateway_integration.get_lambda_integration]
}
