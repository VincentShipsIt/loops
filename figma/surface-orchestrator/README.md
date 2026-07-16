# Figma Surface Orchestrator Programs

This directory is the versioned source of reusable Figma Plugin API programs used by the Figma surface orchestrator.

The Figma MCP `use_figma` action still accepts JavaScript as an inline `code` argument because its remote plugin sandbox cannot import a local file. The orchestrator must therefore render a catalog program locally and pass the rendered output verbatim. It must not rewrite equivalent JavaScript inside the automation prompt.

Keep these programs project-agnostic:

- Put file keys, node ids, expected graph data, and other private product evidence in the private registry, manifest, or an input JSON file.
- Select nodes by exact ids supplied through validated input. Do not rediscover nodes by display name when an exact id is available.
- Return stable structured evidence, including affected node ids for mutations.
- Do not call `figma.closePlugin()` or `figma.notify()`. The MCP runtime owns completion and error reporting.
- Add a new cataloged program when an operation is missing. Do not make an uncataloged one-off `use_figma` call.

## Render a program

Use a private input file for real orchestration payloads:

```sh
python3 scripts/render-figma-program.py inspect-node-text \
  --input-file /absolute/private/input.json
```

Inspect the exact source and rendered hashes for the durable call ledger:

```sh
python3 scripts/render-figma-program.py inspect-node-text \
  --input-file /absolute/private/input.json \
  --format metadata
```

Validate the complete catalog without making a Figma call:

```sh
python3 scripts/render-figma-program.py --check
```

The renderer rejects unknown program ids, path escapes, missing input fields, unknown input fields, duplicate input markers, and forbidden completion calls.
