import boto3
import json
import sys
from awsglue.utils import getResolvedOptions

# Get job arguments
args = getResolvedOptions(sys.argv, ['target_bucket', 'dynamodb_table'])
target_bucket = args['target_bucket'].replace("s3://", "").split("/")[0]
target_key = args['target_bucket'].replace(f"s3://{target_bucket}/", "") + "data.json"

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')
table = dynamodb.Table(args['dynamodb_table'])

# Scan DynamoDB (Best for small to medium tables)
response = table.scan()
data = response['Items']

# Handle pagination if table is larger than 1MB
while 'LastEvaluatedKey' in response:
    response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
    data.extend(response['Items'])

# Convert to JSON and upload to S3
s3.put_object(
    Bucket=target_bucket,
    Key=target_key,
    Body=json.dumps(data)
)




# import pandas as pd
# from pyathena import connect

# conn = connect(s3_staging_dir='s3://your-athena-query-results-bucket/',
#                region_name='us-east-1')
# df = pd.read_sql("SELECT * FROM my_analytics_db.s3_table WHERE status = 'active'", conn)
