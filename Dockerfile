FROM node:22.23.3-bookworm-slim@sha256:c3de60bf2f9dd0ac6370e6117950ff62d6e339527e7472301c9c78a017978392 AS build

RUN npm install --global bun@1.2.21
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY build.ts tsconfig.json ./
COPY src ./src
RUN bun run build

FROM caddy:2.10.2-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d AS caddy

FROM node:22.23.3-bookworm-slim@sha256:c3de60bf2f9dd0ac6370e6117950ff62d6e339527e7472301c9c78a017978392

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates ffmpeg tini \
  && rm -rf /var/lib/apt/lists/* \
  && npm install --global bun@1.2.21

WORKDIR /app
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json Caddyfile entrypoint.sh ./
RUN chmod 755 /app/entrypoint.sh

ENV NODE_ENV=production \
    ELIZA_UI_ENABLE=true \
    SERVER_HOST=0.0.0.0 \
    SERVER_PORT=3000

ENTRYPOINT ["/usr/bin/tini", "--", "/app/entrypoint.sh"]
