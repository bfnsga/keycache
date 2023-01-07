import requests

data = {
    'id': '{uuid}',
    'item': {
        'hello': 'hello'
    }
}

resp = requests.post('https://6cba-73-250-164-216.ngrok.io', json=data)
print(resp.text)