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
  authorizer_credentials = data.aws_iam_role.LabRole.arn
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
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_auth.id
}

# Adicionando a integração com Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth_lambda.invoke_arn

  # Permitir que o API Gateway invoque a função Lambda
  depends_on = [aws_lambda_permission.allow_apigateway]
}

# Permissão para API Gateway invocar o Lambda
resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Opcional: Restringir apenas à API Gateway especificada
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev" # Nome do estágio

  deployment_id = aws_api_gateway_deployment.api_deployment.id

  variables = {
    environment = "development"
  }

  description = "Development stage"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Sempre força a recriação do deployment ao modificar o método ou recurso
  triggers = {
    redeploy = sha1(jsonencode(aws_api_gateway_method.get_method))
  }

  lifecycle {
    create_before_destroy = true
  }
}
