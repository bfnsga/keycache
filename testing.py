import requests
import time

# Get the current time
start_time = time.time()

url = 'https://dm9iu0u138.execute-api.us-east-2.amazonaws.com/example/example'

data = {
    'testing': 'testing'
}

resp = requests.post(url,json=data)
print(resp.text)

# Get the elapsed time
elapsed_time = time.time() - start_time

print(f"Request took {elapsed_time:.2f} seconds")