import { serve } from "bun";

const OLLAMA_URL = "http://127.0.0.1:11434";

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);

    // Serve the UI
    if (url.pathname === "/") {
      return new Response(await Bun.file("index.html").text(), {
        headers: { "Content-Type": "text/html; charset=utf-8" },
      });
    }

    // Chat API endpoint
    if (url.pathname === "/api/chat" && req.method === "POST") {
      try {
        const body = await req.json();
        const model = body.model || "mistral";
        const messages = body.messages || [];

        // Basic safety: limit message size
        if (!Array.isArray(messages) || messages.length > 50) {
          return json({ error: "Too many messages." }, 400);
        }

        const r = await fetch(`${OLLAMA_URL}/api/chat`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            model,
            messages,
            stream: false,
          }),
        });

        if (!r.ok) {
          const text = await r.text();
          return json({ error: "Ollama error", details: text }, 500);
        }

        const data = await r.json();
        return json({
          reply: data?.message?.content ?? "",
        });
      } catch (e: any) {
        return json({ error: "Server error", details: String(e?.message || e) }, 500);
      }
    }

    return new Response("Not Found", { status: 404 });
  },
});

console.log("✅ Chatbot running at http://localhost:3000");
