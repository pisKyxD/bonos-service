# ---------- ETAPA 1: builder ----------
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target /app/packages

# ---------- ETAPA 2: runtime ----------
FROM python:3.12-slim
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=builder /app/packages /app/packages
COPY app/ ./app/

ENV PYTHONPATH=/app/packages

USER appuser
EXPOSE 8004
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]