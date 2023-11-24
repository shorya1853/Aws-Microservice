resource "aws_api_gateway_rest_api" "rest-api" {
  name = "auth-usr"
}

resource "aws_api_gateway_resource" "user-resource" {
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = "user"
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
}


resource "aws_api_gateway_request_validator" "validation" {
  name                        = "para-body-validation"
  rest_api_id                 = aws_api_gateway_rest_api.rest-api.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "user-post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.user-resource.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  request_validator_id = aws_api_gateway_request_validator.validation.id
   request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration" "post-integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest-api.id
  resource_id             = aws_api_gateway_resource.user-resource.id
  http_method             = aws_api_gateway_method.user-post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda-handler.invoke_arn
  request_templates = {
     "application/json" = <<EOF
    {"body": $input.body}
  EOF
  }
}

