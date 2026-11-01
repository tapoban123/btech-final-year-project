import os
from dotenv import load_dotenv
from pinecone import Pinecone

load_dotenv(override=True)

pc = Pinecone(
    api_key=os.getenv("PINECONE_API_KEY")
)

print("Connecting to Pinecone...")

indexes = pc.list_indexes()

print("Pinecone connected successfully!")
print("Available indexes:", indexes)