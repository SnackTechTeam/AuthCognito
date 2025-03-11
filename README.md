# CognitoAuth

Este projeto implementa uma API protegida usando AWS Cognito e um Lambda Authorizer.

## Estrutura do Projeto
lambda/
    ├── lambda_authorizer.py
    └──requirements.txt
terraform/
  ├── api_gateway.tf
  ├── cognito.tf
  ├── lambda.tf
  ├── main.tf
  ├── permissions.tf
  └── provider.tf



## Pré-requisitos

- AWS CLI configurado
- Terraform instalado
- Python 3.8 ou superior

## Configuração

### Terraform

1. Navegue até o diretório `terraform`:
    ```sh
    cd terraform
    ```

2. Inicialize o Terraform:
    ```sh
    terraform init
    ```

3. Aplique a configuração do Terraform:
    ```sh
    terraform apply
    ```

## Arquivos Principais

### Lambda Authorizer

O arquivo [`lambda_authorizer.py`](lambda/lambda_authorizer.py) contém o código do Lambda Authorizer que valida o token JWT.

### Terraform

- [`api_gateway.tf`](terraform/api_gateway.tf): Configura o API Gateway e o Lambda Authorizer.
- [`cognito.tf`](terraform/cognito.tf): Configura o User Pool do Cognito.
- [`lambda.tf`](terraform/lambda.tf): Configura a função Lambda.
- [`permissions.tf`](terraform/permissions.tf): Configura as permissões IAM para a função Lambda.
- [`provider.tf`](terraform/provider.tf): Configura o provedor AWS.

## Uso

Após a configuração, você pode fazer chamadas para a API protegida. Certifique-se de incluir o token JWT no cabeçalho `Authorization` da solicitação.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).