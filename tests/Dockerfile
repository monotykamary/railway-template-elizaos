FROM node:22.22.0-alpine@sha256:e4bf2a82ad0a4037d28035ae71529873c069b13eb0455466ae0bc13363826e34

WORKDIR /app
COPY openai-mock.mjs ./

USER node
EXPOSE 8080
CMD ["node", "openai-mock.mjs"]
