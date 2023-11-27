data "aws_cognito_user_pools" "auth-user" {
  name = "user-management"
}


resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "client"
  user_pool_id                         = "ap-south-1_hKtytL4lo"
  callback_urls                        = ["https://example.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}


resource "aws_api_gateway_authorizer" "api-auth" {
  name = "CognitoUserPoolAuthorizer"
  type = "COGNITO_USER_POOLS"
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  provider_arns = data.aws_cognito_user_pools.auth-user.arns
}