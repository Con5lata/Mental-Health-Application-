from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
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

# Load model and tokenizer once
model_name = "tanusrich/Mental_Health_Chatbot"
model = AutoModelForCausalLM.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

class Question(BaseModel):
    text: str

@app.post("/ask")
async def ask_question(question: Question):
    inputs = tokenizer(question.text, return_tensors="pt").to(device)
    with torch.no_grad():
        output = model.generate(
            **inputs,
            max_new_tokens=200,
            temperature=0.7,
            top_k=50,
            top_p=0.9,
            repetition_penalty=1.2,
            pad_token_id=tokenizer.eos_token_id
        )
    response = tokenizer.decode(output[0], skip_special_tokens=True)
    return {"response": response}