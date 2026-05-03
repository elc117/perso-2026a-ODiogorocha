# Estágio de build (usando imagem oficial do Stack, baseada em Ubuntu 22.04)
FROM fpco/stack-build:lts-22.33 AS builder

WORKDIR /app

# Copiar arquivos de configuração
COPY pokemon_analyzer/stack.yaml pokemon_analyzer/*.cabal ./

# Copiar código fonte
COPY pokemon_analyzer/ .

# Compilar
RUN stack build --system-ghc --copy-bins

# Estágio de runtime (usando Ubuntu 22.04 para compatibilidade de glibc)
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libgmp10 \
    libtinfo6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar binário e frontend
COPY --from=builder /root/.local/bin/pokemon-analyzer-exe /app/pokemon-analyzer-exe
COPY --from=builder /app/frontend.html /app/frontend.html

RUN chmod +x /app/pokemon-analyzer-exe

EXPOSE 3000

CMD ["/app/pokemon-analyzer-exe"]