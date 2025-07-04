# Generated by https://smithery.ai. See: https://smithery.ai/docs/config#dockerfile
FROM node:20-alpine AS builder

# Copy the entire project
COPY . /app
WORKDIR /app

# Use build cache for faster builds
RUN --mount=type=cache,target=/root/.npm npm ci

FROM node:20-alpine AS release

COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

WORKDIR /app

RUN npm ci --ignore-scripts --omit=dev

# Set environment variable for memory bank root
ENV MEMORY_BANK_ROOT=/memory-bank

# Expose port 8102 for supergateway streamable-http
EXPOSE 8102

# Use supergateway to run the memory-bank-mcp service via streamable-http
ENTRYPOINT ["npx", "-y", "supergateway", "--stdio", "node dist/main/index.js", "--outputTransport", "streamableHttp", "--port", "8102"]
