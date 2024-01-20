import * as AWS from 'aws-sdk';
import * as jws from 'jws';

exports.handler = async (event: any, context: any) => {

    console.log(JSON.stringify(event));
    console.log(JSON.stringify(context));

    const secretsManager = new AWS.SecretsManager();
    
    const getSecret = async (secretId: string) => (await secretsManager.getSecretValue({ SecretId: secretId }).promise()).SecretString;

    const privateKey = await getSecret('apple/developer-key');
    const jwsFields = JSON.parse((await getSecret('apple/jws-fields'))!);

    const token = jws.sign({
        header: { alg: 'ES256', kid: jwsFields.kid },
        payload: JSON.stringify({
            iss: jwsFields.iss,
            iat: Date.now() / 1000,
            exp: (Date.now() / 1000) + 3600,
            aud: 'https://appleid.apple.com',
            sub: jwsFields.sub
        }),
        privateKey: privateKey
    })

    const response: any = {
        body: JSON.stringify({ token }),
        isBase64Encoded: false,
        headers: { 'content-type': 'application/json' }
    }

    return response;

}