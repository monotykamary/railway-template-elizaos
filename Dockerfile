FROM node:22.22.0-bookworm-slim@sha256:dd9d21971ec4395903fa6143c2b9267d048ae01ca6d3ea96f16cb30df6187d94 AS build

RUN npm install --global bun@1.2.21
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY build.ts tsconfig.json ./
COPY src ./src
RUN bun run build

FROM caddy:2.10.2-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d AS caddy

FROM node:22.22.0-bookworm-slim@sha256:dd9d21971ec4395903fa6143c2b9267d048ae01ca6d3ea96f16cb30df6187d94

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
