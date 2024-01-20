import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import { Function, Runtime, Code } from 'aws-cdk-lib/aws-lambda';

/**
 * TODO: PLACE YOUR APPLE AUTHORIZER LAMBDA ARN HERE
 */

// REPLACE THE VARIABLE `suffix` with what's in 
// i.e. serverlessrepo-api-gateway-apple-a-AppleAuthorizer-abcdefg
const suffix = undefined;
const authorizerLambdaArn = (region: string, accountId: string) => {
    if (suffix === undefined) {
        throw new Error('Valid ARN cannot be constructed');
    }
    return `arn:aws:lambda:${region}:${accountId}:function:${suffix}`;
}
    

export class ApiGatewayCdkStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props?: cdk.StackProps) {
        super(scope, id, props);
  
        /**
         * DynamoDB
         */
        const userTable = new dynamodb.Table(this, 'UserTable', {
            tableName: 'User',
            partitionKey: { name: 'email', type: dynamodb.AttributeType.STRING }
        });

        /**
         * Permissions
         */
        const putUserPolicyStatement = new iam.PolicyStatement({
            actions: [ 'dynamodb:PutItem' ],
            resources: [ userTable.tableArn ]
        });

        const getUserPolicyStatement = new iam.PolicyStatement({
            actions: [ 'dynamodb:GetItem' ],
            resources: [ userTable.tableArn ]
        });

        const getAppleDeveloperKey = new iam.PolicyStatement({
            actions: [ 'secretsmanager:GetSecretValue'],
            resources: [ 
                `arn:aws:secretsmanager:${cdk.Stack.of(this).region}:${cdk.Stack.of(this).account}:secret:apple/developer-key*`,
                `arn:aws:secretsmanager:${cdk.Stack.of(this).region}:${cdk.Stack.of(this).account}:secret:apple/jws-fields*`
            ]
        });

        /**
         * Lambda
         */
        const userLambda = new Function(this, 'UserLambda', {
            functionName: 'User',
            runtime: Runtime.NODEJS_18_X,
            handler: 'index.handler',
            code: Code.fromAsset('handlers/user'),
            initialPolicy: [
                putUserPolicyStatement,
                getUserPolicyStatement
            ],
            environment: {
                testKey: 'testValue2'
            }
        });

        const retrieveJwtLambda = new Function(this, 'RetrieveJwt', {
            functionName: 'RetrieveJwt',
            runtime: Runtime.NODEJS_18_X,
            handler: 'index.handler',
            code: Code.fromAsset('handlers/retrieveJwt'),
            initialPolicy: [
                getAppleDeveloperKey
            ]
        });

        /**
         * Api Gateway
         */
        const api = new apigateway.RestApi(this, 'siwa-demo-api', {
            deployOptions: {
                cachingEnabled: true,
                cacheTtl: cdk.Duration.minutes(1),
                loggingLevel: apigateway.MethodLoggingLevel.INFO // uncomment this if you have a CW role set up
            }
        });
    
        let appleAuthorizeLambda: cdk.aws_lambda.IFunction | undefined;
        try {
            appleAuthorizeLambda = Function.fromFunctionArn(
                this,
                "apple-authorizer-check",
                authorizerLambdaArn(cdk.Stack.of(this).region, cdk.Stack.of(this).account)
            );
        } catch (e) {
        }

        let appleAuthorizer;
        if (appleAuthorizeLambda !== undefined) {
            appleAuthorizer = new apigateway.TokenAuthorizer(this, 'AppleTokenAuthorizer', {
                handler: Function.fromFunctionArn(
                    this,
                    'apple-authorizer',
                    authorizerLambdaArn(cdk.Stack.of(this).region, cdk.Stack.of(this).account)
                ),
                identitySource: 'method.request.header.Authorization'
            });
        }
        

        const user = api.root.addResource('user');
        user.addMethod('POST', new apigateway.LambdaIntegration(userLambda), {
            authorizer: appleAuthorizer
        });
        user.addMethod('GET', new apigateway.LambdaIntegration(userLambda), {
            authorizer: appleAuthorizer
        });

        const jwt = api.root.addResource('jwt');
        jwt.addMethod('GET', new apigateway.LambdaIntegration(retrieveJwtLambda));
    }
}