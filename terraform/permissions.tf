resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Permissões para Lambda Authorizer"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "cognito-idp:ListUsers"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "execute-api:Invoke"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = "LabRole"#aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
