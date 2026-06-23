# =============================================================================
# docker/Dockerfile -- backend image (FastAPI + pyswip + SWI-Prolog)
# Build context is the project root:  docker build -f docker/Dockerfile -t hcc-backend .
# =============================================================================
FROM python:3.12-slim

# SWI-Prolog is required by pyswip (loads libswipl at runtime).
RUN apt-get update && apt-get install -y --no-install-recommends \
        swi-prolog \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python deps first (better layer caching)
COPY backend/requirements.txt /app/backend/requirements.txt
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# App code + knowledge base
COPY backend /app/backend
COPY prolog  /app/prolog

ENV HCC_KB_DIR=/app/prolog
WORKDIR /app/backend
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
