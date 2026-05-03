# Estágio de build
FROM fpco/stack-build:lts-22.33 AS builder

WORKDIR /app

# Copiar arquivos de configuração primeiro (para cache)
COPY pokemon_analyzer/stack.yaml pokemon_analyzer/stack.yaml.lock pokemon_analyzer/*.cabal ./

# Copiar o código fonte restante
COPY pokemon_analyzer/ .

# Compilar
RUN stack build --system-ghc --copy-bins

# Estágio de runtime
FROM ubuntu:focal

RUN apt-get update && apt-get install -y \
    libgmp10 \
    libtinfo6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar binário e frontend
COPY --from=builder /root/.local/bin/pokemon-analyzer-exe /app/pokemon-analyzer-exe
COPY --from=builder /app/frontend.html /app/frontend.html

EXPOSE 3000

CMD ["/app/pokemon-analyzer-exe"]
