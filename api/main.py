from fastapi import FastAPI, Request, HTTPException
import uuid
import boto3
from dotenv import load_dotenv
import os
import json

try:
    # Load environment variables from .env file
    load_dotenv()

    # Access environment variables
    AWS_ACCESS_KEY = os.getenv('AWS_ACCESS_KEY')
    AWS_SECRET_KEY = os.getenv('AWS_SECRET_KEY')

    # Set up client for S3 with AWS credentials
    s3 = boto3.client(
        's3',
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY,
        region_name='us-east-2'
    )
except:
    pass

app = FastAPI()

@app.post('/')
def root(request: Request, item: dict):
    
    ## Check request size
    max_size = 1024
    content_length = request.headers.get('Content-Length')
    if content_length and int(content_length) > max_size:
        raise HTTPException(
            status_code=413, detail='Too large'
        )

    ## Validate Record
    if 'id' not in item:
        raise HTTPException(
            status_code=413, detail='No ID'
        )

    if 'item' not in item:
        raise HTTPException(
            status_code=413, detail='No record'
        )

    ## ID Processing
    if item['id'] == '{uuid}':
        id = str(uuid.uuid4())
        item['id'] = id

    # Set up bucket, file name, and file
    bucket_name = 'development-2023'
    file_name = f'{id}.json'
    json_data = json.dumps(item)

    s3.put_object(Bucket=bucket_name, Key=file_name, Body=json_data)
    
    ## Return request
    return item

@app.get('/{item_id}')
def root(item_id: str):

    # Set up bucket and file name
    bucket_name = 'development-2023'
    file_name = f'{item_id}.json'

    # Get the file from S3
    response = s3.get_object(Bucket=bucket_name, Key=file_name)

    # Access the file contents
    json_data = response['Body'].read()
    data = json.loads(json_data)

    return data
