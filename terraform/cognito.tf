resource "aws_cognito_user_pool" "main" {
  name = "auth-user-pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
  }
}

resource "aws_cognito_user_pool_client" "app_client" {
  name = "auth-client"
  user_pool_id = aws_cognito_user_pool.main.id
  generate_secret = true

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true
  callback_urls = [var.callback_url]  # Ajuste conforme necessário
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "custom_domain" {
  domain         = var.cognito_domain_name
  user_pool_id   = aws_cognito_user_pool.main.id
}