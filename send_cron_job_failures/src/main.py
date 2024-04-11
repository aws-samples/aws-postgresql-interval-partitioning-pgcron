import json
import boto3

v_sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        response = v_sns.publish(TopicArn=event['sns_topic_arn'], Message=event['message'], Subject="Partition Maintenance job has Errors!!!")
        return {
            'statusCode': 200,
            'body': json.dumps('Notification Sent')
        }
    except Exception as e:
        error_message = f"Failed to send notification: {str(e)}"
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_message})
        }
