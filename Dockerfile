FROM ghcr.io/steamcmd/steamcmd:debian-13
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.bash /
RUN chmod +x /entrypoint.bash
ENTRYPOINT [ "/entrypoint.bash" ]