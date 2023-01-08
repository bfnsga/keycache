import requests

data = {
    'id': '{uuid}',
    'item': {
        'hello': 'hello'
    }
}

resp = requests.post('https://aqkqbkdats.us-east-2.awsapprunner.com', json=data)
print(resp.text)