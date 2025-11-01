# Nombre del binario = nombre del package (ajústalo si tu package no es "bff")
ARG BIN_NAME=bff

FROM rust:1.86 AS builder
ARG BIN_NAME
WORKDIR /app

# deps nativos que aws-lc-sys necesita
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake nasm pkg-config build-essential ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# --- PREBUILD: cachea dependencias ---
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src && echo "fn main(){}" > src/main.rs
# aquí SÍ usamos cache para target (no nos importa perder los artefactos)
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release || true

# --- CÓDIGO REAL ---
COPY . .

# --- BUILD FINAL: SIN mount en /app/target (para que persista) ---
# usamos cache para el registry, pero NO para /app/target
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo build --release --bin ${BIN_NAME} \
 && test -f target/release/${BIN_NAME} \
 && mkdir -p /out \
 && cp target/release/${BIN_NAME} /out/${BIN_NAME}

# ---------- Runtime ----------
FROM debian:bookworm-slim
ARG BIN_NAME
WORKDIR /app
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates
COPY --from=builder /out/${BIN_NAME} ./appbin
EXPOSE 8081
CMD ["./appbin"]
