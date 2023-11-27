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

resource "aws_api_gateway_model" "cred" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  name        = "Credentials"
  content_type = "application/json"
  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "items": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "price": {"type": "number"},
          "quantity": {"type": "integer"}
        },
        "required": ["name", "price", "quantity"]
      }
    },
    "card": {
      "type": "object",
      "properties": {
        "card-no": {"type": "string"},
        "month": {"type": "integer"},
        "expiry-year": {"type": "integer"}
      },
      "required": ["card-no", "month", "expiry-year"]
    }
  },
  "required": ["items", "card"]
}
EOF
}

resource "aws_api_gateway_method" "user-post" {
  depends_on = [ aws_api_gateway_model.cred ]
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api-auth.id
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.user-resource.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  request_validator_id = aws_api_gateway_request_validator.validation.id
  authorization_scopes = ["email"]
  request_parameters = {
  "method.request.header.Content-Type" = true
  "method.request.header.Authorization" = true
  }
  request_models = {
  "application/json" = aws_api_gateway_model.cred.name
  }

}
resource "aws_api_gateway_integration_response" "integration-response-200" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.user-resource.id
  http_method = aws_api_gateway_method.user-post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.user-resource.id
  http_method = aws_api_gateway_method.user-post.http_method
  status_code = "200"
  response_models = {
    "application/json": "Empty"
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
    #set($inputRoot = $input.path('$'))
    {
        "headers": {
            #foreach($param in $input.params().header.keySet())
                "$param": "$util.escapeJavaScript($input.params().header.get($param))"
                #if($foreach.hasNext),#end
            #end
        },
        "body": $input.body,
        "httpMethod": "$context.httpMethod"
    }
  EOF
  }
}

