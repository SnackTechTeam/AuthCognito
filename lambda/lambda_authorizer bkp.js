exports.handler = async (event) => {
    const token = event.authorizationToken?.replace('Bearer ', '');
    
    if (!token) {
        return generatePolicy('anonymous', 'Deny', event.methodArn);
    }

    try {
        // Decodificação manual do JWT (apenas payload)
        const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
        
        return {
            principalId: payload.sub || 'unknown',
            policyDocument: {
                Version: '2012-10-17',
                Statement: [{
                    Action: 'execute-api:Invoke',
                    Effect: 'Allow',
                    Resource: event.methodArn
                }]
            },
            context: {
                userId: payload.sub,
                email: payload.email || ''
            }
        };
    } catch (error) {
        return generatePolicy('anonymous', 'Deny', event.methodArn);
    }
};

function generatePolicy(principalId, effect, resource) {
    return {
        principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [{
                Action: 'execute-api:Invoke',
                Effect: effect,
                Resource: resource
            }]
        }
    };
}