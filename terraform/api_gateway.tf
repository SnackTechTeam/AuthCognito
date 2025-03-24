resource "aws_api_gateway_rest_api" "api" {
  name        = var.projectInfos["name"]
  description = var.projectInfos["description"]
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Authorizer ajustado para o modo TOKEN
resource "aws_api_gateway_authorizer" "lambda_auth" {
  name          = "LambdaAuth"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  authorizer_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.auth_lambda.arn}/invocations"
  type          = "TOKEN"  # Mantenha como TOKEN para JWT
  identity_source = "method.request.header.Authorization"
  
  # Adicione essas linhas:
  authorizer_credentials = data.aws_iam_role.LabRole.arn
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "protected"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_auth.id
  
  # <<< Adicionado para evitar erro 502
  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

# Integração com Lambda (ajustada)
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth_lambda.invoke_arn
  
  # <<< Removido depends_on para simplificar
}


# Deployment e Stage (sem alterações)
resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_method.get_method,
      aws_api_gateway_integration.lambda_integration
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}