import { AgentServer } from "@elizaos/server";
import project from "./index";

const port = Number.parseInt(process.env.SERVER_PORT ?? "3000", 10);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error("SERVER_PORT must be an integer between 1 and 65535");
}
if (!process.env.POSTGRES_URL) {
  throw new Error("POSTGRES_URL is required");
}

const server = new AgentServer();
const agents = project.agents.map((agent) => ({
  character: agent.character,
  plugins: Array.isArray(agent.plugins) ? agent.plugins : [],
  init: agent.init,
}));

await server.start({
  port,
  postgresUrl: process.env.POSTGRES_URL,
  agents,
});

let stopping = false;
const stop = async () => {
  if (stopping) return;
  stopping = true;
  await server.stop();
  process.exit(0);
};

process.on("SIGINT", stop);
process.on("SIGTERM", stop);
