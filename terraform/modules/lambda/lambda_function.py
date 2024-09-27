import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    if event['httpMethod'] == 'POST':
        return increment_visitor_count()
    elif event['httpMethod'] == 'GET':
        return get_visitor_count()
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Unsupported method')
        }

def increment_visitor_count():
    try:
        table.update_item(
            Key={'id': 'visitor_count'},
            UpdateExpression='ADD #count :incr',
            ExpressionAttributeNames={'#count': 'count'},
            ExpressionAttributeValues={':incr': 1}
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Visitor count incremented')
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error incrementing visitor count: {str(e)}')
        }

def get_visitor_count():
    try:
        response = table.get_item(Key={'id': 'visitor_count'})
        count = response.get('Item', {}).get('count', 0)
        return {
            'statusCode': 200,
            'body': json.dumps({'count': count})
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error retrieving visitor count: {str(e)}')
        }
