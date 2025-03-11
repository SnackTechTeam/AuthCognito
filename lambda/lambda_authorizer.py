import json
import jwt # type: ignore
import os

COGNITO_USERPOOL_ID = os.getenv("COGNITO_USERPOOL_ID")
COGNITO_REGION = os.getenv("COGNITO_REGION")

def lambda_handler(event, context):
    token = event.get("authorizationToken")
    
    try:
        decoded_token = jwt.decode(token, options={"verify_signature": False})
        email = decoded_token.get("email")
        user_id = decoded_token.get("sub")  # O "sub" é o ID do usuário

        return {
            "principalId": user_id,
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [{
                    "Action": "execute-api:Invoke",
                    # Allow the user to invoke the API method
                    "Effect": "Allow",
                    "Resource": event["methodArn"]
                }]
            },
            "context": {
                "user_id": user_id,
                "email": email
            }
        }
    except Exception as e:
        print(f"Erro na autenticação: {str(e)}")
        return {
            "principalId": "unauthorized",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [{
                    "Action": "execute-api:Invoke",
                    "Effect": "Deny",
                    "Resource": event["methodArn"]
                }]
            }
        }
