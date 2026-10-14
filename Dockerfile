# SECURE image - expected to PASS the Trivy severity gate.
FROM python:3.12-alpine

ARG GIT_SHA=local
ARG APP_VERSION=1.0.0
ENV BUILD_VARIANT=secure \
    GIT_SHA=${GIT_SHA} \
    APP_VERSION=${APP_VERSION} \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /srv
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/app.py .

# run as non-root
RUN adduser -D -u 10001 appuser
USER appuser

EXPOSE 10000
CMD ["sh", "-c", "gunicorn -b 0.0.0.0:${PORT:-10000} app:app"]
