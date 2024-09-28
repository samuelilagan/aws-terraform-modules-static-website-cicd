import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('views')  

def lambda_handler(event, context):
    # Retrieve the current visitor count
    response = table.get_item(Key={'id': 'visitor_count'})
    
    # Initialize visitor count if it doesn't exist
    if 'Item' not in response:
        visitor_count = 0
        table.put_item(Item={'id': 'visitor_count', 'count': visitor_count})
    else:
        visitor_count = response['Item']['count']

    # Increment visitor count
    visitor_count += 1

    # Update the visitor count back to DynamoDB
    table.update_item(
        Key={'id': 'visitor_count'},
        UpdateExpression='SET #count = :val1',
        ExpressionAttributeNames={'#count': 'count'},
        ExpressionAttributeValues={':val1': visitor_count}
    )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',  # Or specify your domain
            'Access-Control-Allow-Methods': 'OPTIONS,GET,POST',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
        },
        'body': json.dumps({'visitor_count': visitor_count})
    }
