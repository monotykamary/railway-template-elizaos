# ElizaOS on Railway

<!-- The verified Railway deploy button is added after publication. -->

A secured [ElizaOS](https://elizaos.ai/) starter pinned to core/server `1.7.2` and OpenAI plugin `1.6.0`. It deploys one agent, persists state in pgvector, and puts both the dashboard and API behind Caddy Basic Auth. Caddy also injects a private ElizaOS API token, so browser clients never need to store it.

## Architecture

- **ElizaOS**: agent runtime and bundled browser client on private port `3000`.
- **Caddy**: public port `8080`, Basic Auth, health routing, WebSocket-compatible proxying, and API-key injection.
- **pgvector PostgreSQL**: private persistent memories, entities, channels, and embeddings.

Caddy and ElizaOS intentionally share one container because Caddy is the public security boundary for the bundled UI and API. The app service owns the public domain.

## After deployment

1. Open the generated domain and authenticate with `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD`.
2. Confirm the **Eliza** agent is active.
3. Start a chat. Model and embedding requests use `OPENAI_API_KEY`.
4. Customize `src/character.ts`, add pinned plugins to `package.json`, regenerate `bun.lock` with Bun `1.2.21`, and redeploy.

`ELIZA_SERVER_AUTH_TOKEN` and `SECRET_SALT` are independently generated. `POSTGRES_URL` is a pgvector service reference. Do not expose or manually copy these into public client code.

## Important limitations

- An OpenAI API key is required and model usage can incur provider charges.
- The template is a one-agent starter, not a preconfigured multi-agent production system.
- Voice/call and other UDP-dependent integrations are not exposed by this HTTP-only topology.
- HTTP messaging sessions are temporary by upstream design; durable channel messages and agent state remain in PostgreSQL.
- Review third-party plugins before adding them because plugins run with server privileges.

## Updating

Bump compatible ElizaOS packages together, regenerate `bun.lock` with the pinned Bun release, build, and test dashboard auth, direct API denial, model response, embeddings, database migrations, and restart persistence. Source auto-deploys do not update pinned dependencies implicitly.

## Validation fixture

`tests/openai-mock.mjs` is a deterministic OpenAI-compatible Models, Embeddings, and Responses API used only for smoke tests. It is not started by the production image.

## Upstream

- Source: https://github.com/elizaOS/eliza
- Documentation: https://docs.elizaos.ai/
- Core/server release: https://github.com/elizaOS/eliza/releases/tag/v1.7.2
- OpenAI plugin: https://www.npmjs.com/package/@elizaos/plugin-openai/v/1.6.0
- License: [MIT](LICENSE)
