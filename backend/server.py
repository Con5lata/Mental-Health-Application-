from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware  # <-- add this

app = FastAPI(title="Mental Health Chatbot API")

# ✅ Allow requests from your Flutter web app (for dev: allow all)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # in production, restrict this to your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)