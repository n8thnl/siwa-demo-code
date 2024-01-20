import * as AWS from 'aws-sdk';
import { unmarshall } from '@aws-sdk/util-dynamodb';

const ddb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event: any) => {

    let userData: {[key:string]: any} = {};

    let promiseArr: Promise<any>[] = [];

    if (event.httpMethod === 'POST') {

        // POST - try to create new record, return user's record
        const userAttrs = JSON.parse(event.body);

        const params = {
            TableName: "User",
            Item: {
                email: event.requestContext.authorizer.email,
                firstName: userAttrs.firstName,
                lastName: userAttrs.lastName
            },
            ConditionExpression: 'attribute_not_exists(email)',
            ReturnValuesOnConditionCheckFailure: 'ALL_OLD'
        };

        userData.userAttrs = params.Item;
        try {
            await ddb.put(params).promise();
        } catch (e: any) {
            if (e.Item) {
                // Conditional check exception
                console.log(`Item: ${JSON.stringify(e.Item)}`);
                userData.userAttrs = unmarshall(e.Item);
            } else {
                throw e;
            }
        }
        
    } else {

        // GET - retrieve user's record

        const params = {
            TableName: "User",
            Key: {
                email: event.requestContext.authorizer.email
            } 
        };

        promiseArr.push(ddb.get(params).promise());

    }

    const queryParams = {
        TableName: "Route",
        KeyConditionExpression: "#ownerEmail = :ownerEmail",
        ExpressionAttributeNames: {
            "#ownerEmail": "ownerEmail"
        },
        ExpressionAttributeValues: {
            ":ownerEmail": event.requestContext.authorizer.email
        }
    };

    promiseArr.push(ddb.query(queryParams).promise());

    await Promise.all(promiseArr).then(values => {
        console.log(JSON.stringify(values));

        if (values.length == 1) {
            // only routes
            userData.routeAttrs = values[0].Items.sort(routeCompare);
        } else {
            userData.userAttrs = values[0].Item;
            userData.routeAttrs = values[1].Items.sort(routeCompare);
        }
    })
    .catch(err => {
        console.error(`ddb error: ${err}`);
    });

    return {
        isBase64Encoded: false,
        statusCode: userData !== undefined ? 200 : 400,
        headers: {
            'content-type': 'application/json'
        },
        body: JSON.stringify(userData !== undefined ? userData : { 'error': 'user not found' })
    };

}

const routeCompare = (a: any, b: any) => {
    if (a.routeId < b.routeId) {
        return -1;
    }
    if (a.routeId > b.routeId) {
        return 1;
    }
    return 0;
};