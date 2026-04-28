FROM rust:1-slim-bookworm AS builder

ARG FLATC_URL="https://github.com/google/flatbuffers/releases/download/v25.12.19-2026-02-06-03fffb2/Linux.flatc.binary.clang++-18.zip"

WORKDIR /app

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        unzip; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /tmp/flatc; \
    curl -fsSL "$FLATC_URL" -o /tmp/flatc.zip; \
    unzip -q /tmp/flatc.zip -d /tmp/flatc; \
    FLATC_BIN="$(find /tmp/flatc -type f -name flatc | head -n 1)"; \
    test -n "$FLATC_BIN"; \
    install -m 0755 "$FLATC_BIN" /usr/local/bin/flatc; \
    flatc --version; \
    rm -rf /tmp/flatc /tmp/flatc.zip

COPY Cargo.toml Cargo.lock ./
COPY module.fbs ./
COPY data ./data
COPY migrations ./migrations
COPY web ./web
COPY src ./src
COPY nl_parser ./nl_parser

RUN cargo build --release --locked

FROM debian:bookworm-slim AS runtime

WORKDIR /app

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    useradd --system --home-dir /nonexistent --shell /usr/sbin/nologin appuser; \
    mkdir -p /app/certs; \
    chown -R appuser:appuser /app

COPY --from=builder /app/target/release/neverlose-server /app/neverlose-server
COPY --chown=appuser:appuser libraries /app/libraries

USER appuser

EXPOSE 30030 30031 30032

ENTRYPOINT ["./neverlose-server"]
