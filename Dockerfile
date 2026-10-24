FROM node:22.23.4-bookworm-slim@sha256:de170b39439eb0e5a3444ad7d60b015614a381e10fecae2e30ec9e735122f38d AS build

RUN npm install --global bun@1.2.21
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY build.ts tsconfig.json ./
COPY src ./src
RUN bun run build

FROM caddy:2.11.7-alpine@sha256:d8542f48d34a9cf4e4c11a478865229840e87e4c96ea3f439101f31a5d35f75f AS caddy

FROM node:22.23.4-bookworm-slim@sha256:de170b39439eb0e5a3444ad7d60b015614a381e10fecae2e30ec9e735122f38d

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
