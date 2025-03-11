resource "aws_api_gateway_rest_api" "api" {
  name        = var.projectInfos["name"]
  description = var.projectInfos["description"]

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "lambda_auth" {
  name                   = "LambdaAuth"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = aws_lambda_function.auth_lambda.invoke_arn
  authorizer_credentials = data.aws_iam_role.labrole.arn
  type                   = "TOKEN"
  identity_source        = "method.request.header.Authorization"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "protected"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_auth.id
}
