# Deploy and Host ElizaOS on Railway

## About Hosting ElizaOS

ElizaOS is an open-source agent runtime with a browser dashboard, plugin system, persistent memory, and model-provider integrations. This template pins ElizaOS core/server `1.7.2`, OpenAI plugin `1.6.0`, Bun `1.2.21`, and Caddy `2.10.2`.

## Common Use Cases

- Build and host a conversational AI agent
- Prototype persistent agent memory with pgvector
- Develop custom ElizaOS characters and plugins
- Run a private agent dashboard behind authentication

## Dependencies for ElizaOS Hosting

### Deployment Dependencies

The template creates the public **ElizaOS** service and a private **pgvector PostgreSQL** service with persistent storage. `POSTGRES_URL` is a live cross-service reference and must not be replaced with validation credentials.

### Implementation Details

The ElizaOS service owns the public domain. Caddy listens on the Railway port, requires the generated Basic Auth credentials, proxies WebSockets and HTTP to ElizaOS, and injects `ELIZA_SERVER_AUTH_TOKEN`. `/healthz` remains unauthenticated for Railway but checks the upstream agent health and requires one active agent.

The starter creates an **Eliza** agent automatically; there is no separate application administrator. `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` are the access gate. `ELIZA_SERVER_AUTH_TOKEN` and `SECRET_SALT` are generated independently. You must supply `OPENAI_API_KEY` before deployment.

### Why Deploy ElizaOS on Railway?

Railway combines source builds, HTTPS, private pgvector networking, generated secrets, health checks, and persistent storage. The template adds an auditable authentication boundary around the otherwise public starter dashboard.
