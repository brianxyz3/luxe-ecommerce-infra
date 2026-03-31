import json
import base64

def lambda_handler(event, context):

    output = []

    for record in event['records']:
        payload = base64.b64decode(record['data'])
        data = json.loads(payload)

        data['processed_by'] = "lambda"
        
        transformed = base64.b64encode(
            json.dumps(data).encode()
        ).decode()

        output.append({
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': transformed
        })

    return {'records': output}