resource "aws_lambda_function" "auth_lambda" {
  filename         = "../lambda/lambda_authorizer.js.zip"  # Arquivo ZIP contendo apenas o JS
  source_code_hash = filebase64sha256("../lambda/lambda_authorizer.js.zip")
  function_name    = "lambda_authorizer"
  role             = data.aws_iam_role.LabRole.arn
  handler          = "lambda_authorizer.handler"  # Mudou para o export do JS
  runtime          = "nodejs18.x"  # Ou a versão mais recente disponível

  environment {
    variables = {
      COGNITO_USERPOOL_ID = aws_cognito_user_pool.main.id
      COGNITO_REGION      = var.region
      CALLBACK_URL        = var.callback_url
    }
  }
}

# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda-exec-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
