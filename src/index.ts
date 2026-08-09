import bootstrapPlugin from "@elizaos/plugin-bootstrap";
import type { Project } from "@elizaos/core";
import { character } from "./character";

export const projectAgent = {
  character,
  init: async () => {},
  plugins: [bootstrapPlugin],
};

const project: Project = {
  agents: [projectAgent],
};

export default project;
