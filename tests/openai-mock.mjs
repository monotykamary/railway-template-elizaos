import http from "node:http";

const requests = [];
const embedding = Array.from({ length: 1536 }, (_, index) => (index === 0 ? 1 : 0));

const server = http.createServer((request, response) => {
  const chunks = [];
  request.on("data", (chunk) => chunks.push(chunk));
  request.on("end", () => {
    const raw = Buffer.concat(chunks).toString("utf8");
    let body = {};
    try {
      body = raw ? JSON.parse(raw) : {};
    } catch {}
    requests.push({ method: request.method, url: request.url, body });
    console.log(JSON.stringify({ method: request.method, url: request.url, body }));

    if (request.url?.endsWith("/models")) {
      response.setHeader("content-type", "application/json");
      response.end(JSON.stringify({ object: "list", data: [{ id: "gpt-4o", object: "model", created: 0, owned_by: "validation" }] }));
      return;
    }

    if (request.url?.endsWith("/embeddings")) {
      response.setHeader("content-type", "application/json");
      response.end(JSON.stringify({ object: "list", data: [{ object: "embedding", index: 0, embedding }], model: "text-embedding-3-small", usage: { prompt_tokens: 1, total_tokens: 1 } }));
      return;
    }

    const content = '<response><thought>The validation prompt requests a deterministic reply.</thought><actions>REPLY</actions><providers></providers><text>Railway validation response.</text></response>';

    if (request.url?.endsWith("/responses")) {
      response.setHeader("content-type", "application/json");
      response.end(JSON.stringify({
        id: "resp_validation",
        object: "response",
        created_at: Math.floor(Date.now() / 1000),
        status: "completed",
        error: null,
        incomplete_details: null,
        instructions: null,
        max_output_tokens: null,
        model: body.model ?? "gpt-4o",
        output: [{
          id: "msg_validation",
          type: "message",
          status: "completed",
          role: "assistant",
          content: [{ type: "output_text", annotations: [], logprobs: [], text: content }],
        }],
        parallel_tool_calls: true,
        previous_response_id: null,
        reasoning: { effort: null, summary: null },
        store: false,
        temperature: 0.7,
        text: { format: { type: "text" } },
        tool_choice: "auto",
        tools: [],
        top_p: 1,
        truncation: "disabled",
        usage: {
          input_tokens: 10,
          input_tokens_details: { cached_tokens: 0 },
          output_tokens: 10,
          output_tokens_details: { reasoning_tokens: 0 },
          total_tokens: 20,
        },
        metadata: {},
      }));
      return;
    }

    if (request.url?.endsWith("/chat/completions")) {
      if (body.stream) {
        response.writeHead(200, { "content-type": "text/event-stream", "cache-control": "no-cache" });
        response.write(`data: ${JSON.stringify({ id: "chatcmpl-validation", object: "chat.completion.chunk", created: Math.floor(Date.now() / 1000), model: body.model ?? "gpt-4o-mini", choices: [{ index: 0, delta: { role: "assistant", content }, finish_reason: null }] })}\n\n`);
        response.write(`data: ${JSON.stringify({ id: "chatcmpl-validation", object: "chat.completion.chunk", created: Math.floor(Date.now() / 1000), model: body.model ?? "gpt-4o-mini", choices: [{ index: 0, delta: {}, finish_reason: "stop" }], usage: { prompt_tokens: 10, completion_tokens: 10, total_tokens: 20 } })}\n\n`);
        response.end("data: [DONE]\n\n");
      } else {
        response.setHeader("content-type", "application/json");
        response.end(JSON.stringify({ id: "chatcmpl-validation", object: "chat.completion", created: Math.floor(Date.now() / 1000), model: body.model ?? "gpt-4o-mini", choices: [{ index: 0, message: { role: "assistant", content }, finish_reason: "stop" }], usage: { prompt_tokens: 10, completion_tokens: 10, total_tokens: 20 } }));
      }
      return;
    }

    if (request.url === "/requests") {
      response.setHeader("content-type", "application/json");
      response.end(JSON.stringify(requests));
      return;
    }

    response.statusCode = 404;
    response.end("not found");
  });
});

server.listen(8080, "0.0.0.0", () => console.log("mock ready"));
