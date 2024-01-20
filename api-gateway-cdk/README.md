# SIWA CDK Demo Code
Welcome! This code is meant to be deployed alongside the api-gateway-apple-authorizer Serverless Application Repository (SAR) application.

## How to Deploy
1. Create the following two secrets in *Secrets Manager*
  - `apple/developer-key`: your apple developer private key pasted as plaintext
  - `apple/jws-fields`: JSON object in the following form:
    ```
    {
        "kid": "the-apple-kid-you-use",
        "iss": "your-10-character-team-id",
        "sub": "your-bundle-id-ie-com.example.myapp"
    }
    ```
2. In the root folder, run `npm i`
3. In each `handlers` subfolder, run `npm i`
3. In `bin/api-gateway-cdk.ts`, populate your account and region where stated
4. In the root folder (same as where this README is), run `npm run build`
5. If you've not bootstrapped your account/region, you will need to run `cdk bootstrap aws://ACCOUNT-NUMBER/REGION`
6. Run `cdk deploy`
7. After deploying the `api-gateway-apple-authorizer` SAR application, retrieve the lambda name for the authorizer and populate it in `lib/api-gateway-cdk-stack.ts` in the `suffix` variable.
8. Run `cdk deploy` once again. 

**Note**: if anything goes wrong during deployment and you need to delete the stack and start over, you will need to manually delete the DynamoDB table `Users`.
