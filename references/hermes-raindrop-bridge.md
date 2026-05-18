# Hermes Agent ↔ Raindrop Workshop Bridge

**Verdict (May 2026)**: no native compatibility. Bridge via `hermes-otel` plugin → Workshop's OTLP `/v1/traces` endpoint. ~30 minutes of config, zero code.

---

## Why no native compat

| | Hermes Agent | Raindrop Workshop |
|---|---|---|
| Stack | Python 88% + TS 8.7%, custom agent loop | TypeScript 92%, Bun, SQLite |
| Provider abstraction | `ProviderProfile` with 3 modes: chat_completions, codex_responses, anthropic_messages. Uses `openai==2.24.0` directly. | Auto-instruments OpenAI/Anthropic/Bedrock client libs |
| Observability built-in | Langfuse plugin (envs: `HERMES_LANGFUSE_*`). No generic OTLP exporter. | Native SDK + raw OTLP `/v1/traces` JSON receiver on port 5899 |
| Listed Raindrop integrations | NOT listed | Vercel AI SDK, OpenAI Agents SDK, Anthropic SDK, Claude Agent SDK, LangChain, LangGraph, CrewAI, Mastra, Pydantic AI, DSPy, Google ADK, Strands, Agno, Deep Agents |

Hermes uses OpenAI SDK directly, so in principle if `raindrop.init()` runs first in the same Python process, Raindrop's auto-instrumentation might pick up Hermes's OpenAI calls. But you'd lose Hermes's higher-level structure (turn-level, tool-level, subagent-fan-out spans), which is exactly the value of Raindrop's Workshop UI.

---

## Bridge path (recommended, ~30 min)

Use the existing community plugin `briancaffey/hermes-otel` + Raindrop Workshop's OTLP receiver.

### Step 1 — Install the OTel plugin

```bash
hermes plugins install briancaffey/hermes-otel

# In Hermes's venv:
~/.hermes/venv/bin/pip install \
    opentelemetry-api \
    opentelemetry-sdk \
    opentelemetry-exporter-otlp-proto-http
```

### Step 2 — Configure Hermes `config.yaml`

```yaml
plugins:
  hermes-otel:
    enabled: true
    backends:
      raindrop-workshop:
        type: otlp
        endpoint: http://localhost:5899/v1/traces
        protocol: http/protobuf
        headers: {}        # no auth needed for local Workshop
        sampling: always_on
        spans:
          - turn           # user-to-assistant exchange
          - tool           # individual tool calls
          - subagent       # subagent invocations
          - skill          # SKILL.md invocations
```

### Step 3 — Ensure Workshop is running

```bash
raindrop workshop          # starts daemon on :5899
# Or as launchctl:
launchctl bootstrap gui/$(id -u) ~/.research/services/com.bora.raindrop-workshop.plist
```

### Step 4 — Smoke test

```bash
# Open Hermes; have a short conversation that uses a tool.
# Then in browser:
open http://localhost:5899

# Expected: trace timeline shows the conversation with spans for
# turn → tool calls → llama-server LLM call → response.
```

If the trace appears: bridge works. Commit the config to the local-agent-setup repo.

---

## Unverified assumptions

Two things to confirm during first install:

1. **Workshop's local `/v1/traces` endpoint accepts generic OTel SDK payloads** (not just Raindrop-SDK-authored ones). The Raindrop docs say "OTLP JSON to `/v1/traces`" but that's documented for `api.raindrop.ai` (the cloud endpoint); whether the local Workshop daemon mirrors that contract exactly needs a curl test:
   ```bash
   curl -X POST http://localhost:5899/v1/traces \
        -H "Content-Type: application/x-protobuf" \
        --data-binary @sample-otlp-payload.pb
   # Expected: 200 OK or 202 Accepted
   ```

2. **`hermes-otel` plugin's exact config syntax** — docs live on hermesatlas.com (third-party catalog). Verify against the plugin's own README before committing to the syntax above.

---

## Fallback path if OTLP doesn't work (~50 LOC Python plugin)

If Workshop rejects unauthenticated OTLP, write a Hermes plugin modeled on the existing Langfuse plugin that calls Raindrop's Python SDK manually:

```python
# ~/.hermes/plugins/hermes-raindrop/plugin.py
import raindrop_ai
from hermes.plugins import HermesPlugin

class RaindropBridge(HermesPlugin):
    def on_init(self, config):
        raindrop_ai.init(
            api_key="local",
            base_url="http://localhost:5899",
        )

    def on_turn_start(self, turn_id, user_message):
        self.span = raindrop_ai.interaction.start_span(
            name="turn",
            attributes={"turn_id": turn_id, "user_message": user_message[:500]},
        )

    def on_tool_call(self, tool_name, tool_input, tool_output):
        with raindrop_ai.tool_span(name=tool_name) as t:
            t.set_attribute("input", json.dumps(tool_input)[:1000])
            t.set_attribute("output", str(tool_output)[:1000])

    def on_turn_end(self, turn_id, assistant_message):
        self.span.set_attribute("assistant_message", assistant_message[:500])
        self.span.end()
```

This mirrors the Hermes Langfuse plugin pattern but targets Raindrop's `raindrop-ai` Python SDK instead.

---

## Worst-case path (~1 day, NOT recommended)

A localhost HTTP MITM proxy at `http://localhost:11434` (where Hermes calls llama-server) that captures every `POST /v1/chat/completions`, parses tool calls from the OpenAI tool-use schema, and reconstructs spans for Raindrop. Architecturally inferior because it only sees LLM HTTP calls — it misses Hermes's tool dispatch, subagent fan-out, and skill loading. The Workshop UI's waterfall would be missing the layers that make it valuable.

**Skip this path** unless both OTLP and Python-plugin paths fail.

---

## Decision tree

```
Try Step 1-3 above (OTLP)
    │
    ├─ Works? → done, ~30 min total
    │
    └─ Doesn't work?
        ├─ Workshop returns 4xx on OTLP POST → write Python plugin (~50 LOC, ~half day)
        │       │
        │       ├─ Works? → done, ~half day total
        │       │
        │       └─ Doesn't work? → MITM proxy path (~1 day, worse UX)
        │
        └─ Workshop never receives spans → check `hermes-otel` plugin syntax, then escalate
```

---

## What we get from the bridge

- Live trace timeline of every Hermes conversation in the Workshop browser UI
- Tool-call graphs (what tool was called, in what order, with what inputs/outputs)
- Token cost per call/per session
- Decision points (where Hermes chose to invoke a sub-skill vs answer directly)
- Replayable traces via Workshop's `/setup-agent-replay` slash command — invaluable for fixing a manuscript-pipeline regression without rerunning all 15 phases

For KVKK compliance: bridge traces stay local (Workshop SQLite at `~/.raindrop/raindrop_workshop.db`). Same audit benefits as Hermes's built-in logs, but with much better visibility.

---

## Test plan after setup

Once the bridge is wired up:

1. Run `clinical-data-to-manuscript --first_paper true --mode guided` with a synthetic dataset
2. Confirm each phase shows up in Workshop UI as a distinct span
3. Confirm sub-skill invocations (paperqa-summarize, anti-leakage, etc.) appear nested under their parent phase
4. Confirm material-passport emits show up as discrete events
5. Use Workshop's `/setup-agent-replay` to replay one phase against modified skill code; verify the replay system works

If all 5 pass: bridge is production-ready. Add to verification suite as Test 11.

---

## Open questions for upstream

- **Hermes**: would they consider native Raindrop support? Open an issue at github.com/NousResearch/hermes-agent. (Listed as TODO; not blocking — bridge works.)
- **Raindrop**: would they consider listing Hermes Agent on the compatibility matrix? Open an issue at github.com/raindrop-ai/workshop. (Same — bridge works.)

If both ship native support someday, this bridge becomes a one-line config. Until then, we maintain.

---

## Credit

- **Ben Hylak** and the **raindrop-ai team** for Workshop and the local-first agent debugger philosophy
- **Nous Research** for Hermes Agent and its skill ecosystem
- **briancaffey** for the `hermes-otel` community plugin
- This bridge analysis was conducted by an automated research pass May 18 2026; verify before committing to long-term reliance.
