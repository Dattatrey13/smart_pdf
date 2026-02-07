from pydantic import BaseModel


class UploadResponse(BaseModel):
    doc_id: str
    num_chunks: int


class AskRequest(BaseModel):
    doc_id: str
    question: str


class AskResponse(Base