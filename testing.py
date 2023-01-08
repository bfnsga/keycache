import requests

url = ' https://dm9iu0u138.execute-api.us-east-2.amazonaws.com/example'

data = {
    'testing': 'testing'
}

resp = requests.post(url,json=data)
print(resp.text)