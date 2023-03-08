import requests
import os

def lambda_handler(event, context):
    
    product_id = event.get("id", 1)
    
    print(f"Received product id: {product_id}")
    print(f"Environment: {os.environ['ENVIRONMENT']}")

    response = requests.get("https://reqres.in/api/products/3")

    if response.status_code != 200:
        raise Exception("Request was not successful")
    
    return response.json()