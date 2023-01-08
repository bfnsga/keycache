import requests
import time

# Get the current time
start_time = time.time()

item_id = '202c6c25-dc68-4812-912b-64e3d0692a8a'

resp = requests.get(f'https://aqkqbkdats.us-east-2.awsapprunner.com/{item_id}')
print(resp.text)

# Get the elapsed time
elapsed_time = time.time() - start_time

print(f"Request took {elapsed_time:.2f} seconds")