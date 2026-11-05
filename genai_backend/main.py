from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI

from api.documents import router as documents_router

app = FastAPI()
app.include_router(documents_router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"message": "Hello World"}
