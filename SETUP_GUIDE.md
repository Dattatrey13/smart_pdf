# Smart PDF Reader - Complete Setup Guide

This is an AI-powered PDF reader that uses Google Gemini API for intelligent PDF analysis. The project consists of:
- **Backend**: FastAPI server with PDF processing and Gemini integration
- **Frontend**: Flutter mobile app for PDF interaction

## Architecture Overview

```
┌─────────────────────┐
│  Flutter App        │
│  (Chat, Summary,    │
│   Search, Ask)      │
└──────────┬──────────┘
           │ HTTP/REST
           ▼
┌─────────────────────────────┐
│  FastAPI Backend            │
│  - PDF Upload & Text Extract│
│  - Text Chunking            │
│  - Embedding Generation     │
│  - Semantic Search          │
│  - AI Responses (Gemini)    │
└─────────────────────────────┘
           ▲
           │
           ▼
     Google Gemini API
```

## Backend Setup

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Create and Activate Virtual Environment
**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**macOS/Linux:**
```bash
python -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Environment Configuration
The `.env` file is already configured with your Gemini API key:
```
GEMINI_API_KEY=AIzaSyBi--P8W3vjBQ78jJdhApECL416o96JITw
```

**⚠️ IMPORTANT**: In production, keep your API key secure:
- Add `.env` to `.gitignore`
- Use environment variables from your deployment platform
- Rotate API keys regularly

### 5. Run the Backend Server
```bash
python -m uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`

**API Documentation**: Visit `http://localhost:8000/docs` in your browser

## Backend API Endpoints

### 1. Upload PDF
```
POST /upload
```
Upload a PDF file for processing.
- **Input**: PDF file
- **Output**: 
```json
{
  "doc_id": "unique-id",
  "num_chunks": 42
}
```

### 2. Ask a Question
```
POST /ask
```
Ask a question about the uploaded PDF.
- **Input**:
```json
{
  "doc_id": "unique-id",
  "question": "What is this document about?"
}
```
- **Output**:
```json
{
  "answer": "Based on the PDF content..."
}
```

### 3. Get Summary
```
POST /summary
```
Generate a summary of the PDF.
- **Input**:
```json
{
  "doc_id": "unique-id"
}
```
- **Output**:
```json
{
  "summary": "This document covers..."
}
```

### 4. Search
```
POST /search
```
Semantic search within the PDF.
- **Input**:
```json
{
  "doc_id": "unique-id",
  "query": "search term"
}
```
- **Output**:
```json
{
  "hits": [
    {
      "text": "relevant text chunk",
      "score": 0.95
    }
  ]
}
```

## Flutter Frontend Setup

### 1. Navigate to Flutter App Directory
```bash
cd pdf_app
```

### 2. Get Flutter Dependencies
```bash
flutter pub get
```

### 3. Update API Connection (Important!)

Edit `lib/api_service.dart` and update the `baseUrl`:

**For Android Emulator** (default):
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**For Physical Device**:
```dart
static const String baseUrl = 'http://YOUR_PC_IP:8000';
```
(Replace `YOUR_PC_IP` with your computer's actual IP address, e.g., `192.168.1.100`)

### 4. Run the Flutter App

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d web
```

## Feature Overview

### 1. **Chat/Ask AI**
- Upload a PDF
- Ask questions about its content
- Get AI-powered answers based on the document

### 2. **Summary**
- Generate automatic summaries of PDF content
- Structured with bullet points and headings

### 3. **Quick Search**
- Semantic search through the document
- Find relevant sections based on meaning, not just keywords
- Returns relevance scores

## Testing the Integration

### Step 1: Start Backend
```bash
cd backend
python -m uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### Step 2: Test API with cURL
```bash
# Test if backend is running
curl http://localhost:8000/

# Upload a PDF (replace path/to/test.pdf)
curl -X POST -F "file=@path/to/test.pdf" http://localhost:8000/upload

# You'll get: {"doc_id":"xyz","num_chunks":10}
# Use this doc_id for subsequent requests

# Ask a question
curl -X POST http://localhost:8000/ask \
  -H "Content-Type: application/json" \
  -d '{"doc_id":"xyz","question":"What is the main topic?"}'
```

### Step 3: Run Flutter App
```bash
cd pdf_app
flutter run
```

## Troubleshooting

### Backend Issues

**"GEMINI_API_KEY not set" error**
- Check `.env` file exists in the backend directory
- Ensure environment variable is loaded: `from dotenv import load_dotenv`

**"Connection refused" from Flutter**
- On Android emulator: Use `10.0.2.2` (not `localhost`)
- On physical device: Update to your computer's IP address
- Make sure backend is running on `0.0.0.0:8000`

**PDF text extraction fails**
- Some PDFs have scanned images instead of text
- Current implementation uses PyPDF2 (text-based)
- For scanned PDFs, consider OCR solutions

### Flutter Issues

**"No document uploaded" error**
- Upload a PDF first before asking questions
- Check that the upload completed successfully

**Network timeout**
- Verify backend server is running
- Check correct IP/port in api_service.dart
- Ensure device can reach the server (same network)

## Performance Optimization

### For Production:

1. **Persistent Storage**: Replace in-memory `DOC_STORE` with a database
2. **Caching**: Cache embeddings to avoid recalculation
3. **Rate Limiting**: Add rate limiting to prevent abuse
4. **Authentication**: Implement API key authentication
5. **Scaling**: Use managed services for embeddings and LLM

### Recommended Stack:
- **Database**: PostgreSQL with pgvector for embeddings
- **Cache**: Redis for session management
- **Hosting**: Docker containerization on cloud (AWS, GCP, Azure)
- **API Gateway**: Rate limiting and authentication layer

## Project Structure

```
smart_pdf/
├── backend/
│   ├── app.py                 # Main FastAPI application
│   ├── llm_client.py          # Gemini API integration
│   ├── pdf_utils.py           # PDF extraction and chunking
│   ├── model.py               # Pydantic data models
│   ├── requirements.txt        # Python dependencies
│   ├── .env                   # Environment variables
│   └── main.py                # Alternative entry point
├── pdf_app/                   # Flutter frontend
│   ├── lib/
│   │   ├── main.dart          # App entry & home screen
│   │   ├── api_service.dart   # Backend API client
│   │   └── chat_screen.dart   # Chat interface
│   └── pubspec.yaml           # Flutter dependencies
└── SETUP_GUIDE.md            # This file
```

## Key Technologies

- **Backend**: FastAPI, Python, Google Generative AI
- **Frontend**: Flutter, Dart
- **PDF Processing**: PyPDF2
- **Embeddings**: Google's embedding-001 model
- **LLM**: Google Gemini Pro

## API Key Security

Your Gemini API key is configured. For security best practices:

1. **Never commit .env to Git**
2. **Use different keys for dev/prod**
3. **Rotate keys regularly**
4. **Monitor API usage** in Google Cloud Console
5. **Use API key restrictions** (HTTP referrers, IP addresses)

## Next Steps

1. ✅ Backend is running on `localhost:8000`
2. ✅ API key is configured
3. 🔄 Update Flutter app with your PC's IP address
4. 🎯 Run the Flutter app and test with a sample PDF
5. 📈 Enhance with features like:
   - PDF viewer integration
   - Multi-document comparison
   - Export summaries
   - User authentication

## Support & Debugging

Enable verbose logging:

**Backend**:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

**Flutter**:
```bash
flutter run -v
```

## License & Notes

- This is a template for AI-powered PDF analysis
- Customize prompts in `app.py` for your use case
- Adjust chunk sizes and embedding parameters as needed

---

**Last Updated**: February 2026
**Status**: ✅ Ready for Development
