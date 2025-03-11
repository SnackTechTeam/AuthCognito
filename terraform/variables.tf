variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "callback_url" {
  description = "Callback URL for Cognito"
  default     = "https://auth-cognito-videoup.com/callback"
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
