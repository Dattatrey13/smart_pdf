import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

model = genai.GenerativeModel("gemini-pro")

def ask_gemini(context, question):
    prompt = f"""
    Answer the question using ONLY the context below.
    If the answer is not found in the context, say "I could not find an answer in the provided PDF."

    Context:
    {context}

    Question:
    {question}
    """
    response = model.generate_content(prompt)
    return response.text


def summarize_text(text):
    prompt = f"""
    Summarize the following PDF in bullet points:

    {text}
    """
    response = model.generate_content(prompt)
    return response.text
