variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "callback_url" {
  description = "Callback URL for Cognito"
  default     = "https://auth-vidsnap-domain-example.com/callback"
}

variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "projectInfos" {
  default = {
    name        = "auth-api"
    description = "API protegida pelo Cognito + Lambda Authorizer"
  }
  description = "Informações sobre o projeto"
}

variable "cognito_domain_name" {
  description = "Custom domain name for the Cognito User Pool"
  type        = string
  default     = "auth-vidsnap-domain-example"  # Substitua pelo nome do domínio desejado
}
