resource "aws_api_gateway_rest_api" "api" {
  name        = var.projectInfos["name"]
  description = var.projectInfos["description"]
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name          = "CognitoAuth"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.main.arn]
  identity_source = "method.request.header.Authorization"
  # Adicione esta linha para garantir que aceite access_token:
  authorizer_result_ttl_in_seconds = 0  # Desativa cache para testes
  identity_validation_expression = ".*"  # Aceita qualquer token válido
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "protected"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
  authorization_scopes = ["aws.cognito.signin.user.admin"]  # Escopo obrigatório

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

#Com Mock. Retirar esse trecho e descomentar o debaixo  para usar com a API em .NET
resource "aws_api_gateway_integration" "http_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "MOCK"  # Altere de HTTP para MOCK
  passthrough_behavior    = "WHEN_NO_MATCH"
  
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
      message    = "Success! Token is valid."
    })
  }
}

# resource "aws_api_gateway_integration" "http_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.my_resource.id
#   http_method             = aws_api_gateway_method.post_method.http_method
#   integration_http_method = "POST"
#   type                    = "HTTP"
#   uri                     = "https://meuapp.com/api/protected" # URL da sua API em .NET

#   request_parameters = {
#     "integration.request.header.Authorization" = "method.request.header.Authorization"
#   }

#   request_templates = {
#     "application/json" = <<EOF
# {
#   "body": $input.json('$'),
#   "headers": {
#     "Authorization": "$input.params('Authorization')"
#   }
# }
# EOF
#   }
# }

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_method.post_method,
      aws_api_gateway_integration.http_integration
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}