# ── Stage 1: dependencias ────────────────────────────────────────────────────
FROM oven/bun:1.3.11-alpine AS deps

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile --production

# ── Stage 2: builder (DEV — hot reload) ──────────────────────────────────────
FROM oven/bun:1.3.11-alpine AS builder

WORKDIR /app

# En dev necesitamos devDependencies también (tsc, etc.)
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

# Este stage lo usa docker-compose en dev (sin compilar, bun run start:dev)
# Y también sirve de base para el stage de producción

RUN bun run build

# ── Stage 3: runner PRODUCCIÓN (imagen final mínima) ─────────────────────────
FROM oven/bun:1.3.11-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/dist         ./dist
COPY --from=deps    /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/v1/health || exit 1

CMD ["bun", "dist/main.js"]