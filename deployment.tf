resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id

  triggers = {
    redeployment = sha1(jsonencode(
      [
        aws_api_gateway_method.user-post.id,
        aws_api_gateway_integration.post-integration.id,     
        aws_api_gateway_resource.user-resource.id
      ]
      ))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage_prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  stage_name    = "prod"
}