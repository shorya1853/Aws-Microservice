provider "aws" {
    profile = "boto_usr"
    region = "ap-south-1"
}

# data "archive_file" "api_lambda_code_data" {
#   type        = "zip"
#   source_dir  = "PaymentMethod/"
#   output_path = "PaymentMethod/"
# }

data "aws_iam_role" "role" {
  name = "lambda_to_sqs-role-4rgy4sh4"
}

resource "aws_lambda_permission" "post-lambda-permission" {
  statement_id  = "Allowlambda_handler-postInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_handler"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:893711537471:${aws_api_gateway_rest_api.rest-api.id}/*/${aws_api_gateway_method.user-post.http_method}${aws_api_gateway_resource.user-resource.path}"
}


resource "aws_lambda_function" "lambda-handler" {
    function_name = "lambda_handler"
    role = data.aws_iam_role.role.arn
    runtime = "python3.10"
    handler ="lambda_function.lambda_handler"
    filename = "PaymentMethod"
  
}