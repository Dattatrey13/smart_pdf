import uuid
from typing import Dict, List

import numpy as np
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from llm_client import LLMClient
from pdf_utils import extract_text_from_pdf, chunk_text
from models import (
    UploadResponse,
    AskRequest,
    AskResponse,
    SummaryRequest,
    SummaryResponse,
    SearchRequest,
    SearchResponse,
    SearchHit,
)
from pdf_utils import top_k_chunks


app = FastAPI(title="Smart PDF Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

llm = LLMClient()

# In-memory store: doc_id -> {chunks, embeddings}
DOC_STORE: Dict[str, Dict[str, object]] = {}


@app.post("/upload", response_model=UploadResponse)
async def upload_pdf(file: UploadFile = File(...)):
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")

    content = await file.read()
    text = extract_text_from_pdf(content)
    if not text.strip():
        raise HTTPException(status_code=400, detail="Could not extract text from PDF")

    chunks = chunk_text(text, max_tokens=400)
    if not chunks:
        raise HTTPException(status_code=400, detail="No chunks created")

    embeddings = await llm.embed(chunks)
    emb_array = np.array(embeddings, dtype="float32")

    doc_id = str(uuid.uuid4())
    DOC_STORE[doc_id] = {
        "chunks": chunks,
        "embeddings": emb_array,
    }

    return UploadResponse(doc_id=doc_id, num_chunks=len(chunks))


@app.post("/ask", response_model=AskResponse)
async def ask_question(body: AskRequest):
    if body.doc_id not in DOC_STORE:
        raise HTTPException(status_code=404, detail="Unknown doc_id")

    store = DOC_STORE[body.doc_id]
    chunks: List[str] = store["chunks"]  # type: ignore
    emb_array: np.ndarray = store["embeddings"]  # type: ignore

    # embed the question
    q_emb_list = await llm.embed([body.question])
    q_emb = np.array(q_emb_list[0], dtype="float32")
    top_chunks = top_k_chunks(q_emb, emb_array, chunks, k=5)

    context = "\n\n".join([c for c, _ in top_chunks])
    system_prompt = (
        "You are an AI assistant that answers questions based ONLY on the "
        "provided PDF context. If the answer is not in the context, say you "
        "don't know."
    )
    user_prompt = f"Context:\n{context}\n\nQuestion: {body.question}\n\nAnswer in detail:"

    answer = await llm.generate(system_prompt, user_prompt)
    return AskResponse(answer=answer.strip())


@app.post("/summary", response_model=SummaryResponse)
async def summarize(body: SummaryRequest):
    if body.doc_id not in DOC_STORE:
        raise HTTPException(status_code=404, detail="Unknown doc_id")

    store = DOC_STORE[body.doc_id]
    chunks: List[str] = store["chunks"]  # type: ignore

    # limit context to first N chunks
    max_chunks = 10
    context = "\n\n".join(chunks[:max_chunks])

    system_prompt = (
        "You are an expert summarizer. Create a concise, structured summary "
        "of the provided PDF content. Use headings and bullet points."
    )
    user_prompt = f"PDF Content:\n{context}\n\nWrite a high-level summary:"

    summary = await llm.generate(system_prompt, user_prompt)
    return SummaryResponse(summary=summary.strip())


@app.post("/search", response_model=SearchResponse)
async def search(body: SearchRequest):
    if body.doc_id not in DOC_STORE:
        raise HTTPException(status_code=404, detail="Unknown doc_id")

    store = DOC_STORE[body.doc_id]
    chunks: List[str] = store["chunks"]  # type: ignore
    emb_array: np.ndarray = store["embeddings"]  # type: ignore

    q_emb_list = await llm.embed([body.query])
    q_emb = np.array(q_emb_list[0], dtype="float32")
    top_chunks = top_k_chunks(q_emb, emb_array, chunks, k=5)

    hits = [
        SearchHit(text=text, score=score)
        for text, score in top_chunks
    ]

    return SearchResponse(hits=hits)


@app.get("/")
async def root():
    return JSONResponse({"status": "ok", "message": "Smart PDF backend running"})