FROM ghcr.io/steamcmd/steamcmd:debian-13
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.mjs /
ENTRYPOINT [ "node", "/entrypoint.mjs" ]