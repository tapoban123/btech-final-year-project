import requests
from dotenv import load_dotenv
load_dotenv()
import os
print("Hi")
api_key = os.environ.get("XAI_API_KEY")
url = "https://api.groq.com/openai/v1/models"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers)

print(response.json())