FROM node:22.22.0-alpine@sha256:98966949450ee04efbd3453ebd405eb8780d1e5ee86cc0ff778422147195f8f9

WORKDIR /app
COPY openai-mock.mjs ./

USER node
EXPOSE 8080
CMD ["node", "openai-mock.mjs"]
