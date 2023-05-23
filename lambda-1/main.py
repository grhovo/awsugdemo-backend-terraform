import json

def lambda_handler(event, context):
    return {
    'headers': {
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
    },
    'statusCode': 200,
        'body': json.dumps({'message': 'Hello from the video endpoint, we for now we do not have anything!'})
    }