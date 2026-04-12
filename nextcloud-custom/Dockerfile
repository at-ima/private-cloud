FROM nextcloud:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY hooks/before-starting/01-preview-config.sh /docker-entrypoint-hooks.d/before-starting/01-preview-config.sh
RUN chmod +x /docker-entrypoint-hooks.d/before-starting/01-preview-config.sh
