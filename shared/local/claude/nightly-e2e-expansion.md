# Claude Scheduled Task: Nightly E2E Footprint Expansion

Use this for a high-effort recurring task that adds exactly one isolated e2e
spec per run.

## Prompt


Run high-effort autonomous mode. Use subagents or workflow orchestration for discovery, verification, and critique when available.

Goal:

- Extend the nightly e2e coverage footprint by exactly one new product-area spec per run.
- The new spec must cover a real product surface not yet exercised.
- Do not add a batch of specs.

Resource limits:

- Do not run e2e specs locally.
- Do not start Docker, dev servers, or full builds locally.
- Allowed local gates are static formatting/linting and test discovery/compile-only commands when available.
- The new spec is exercised by CI/nightly infrastructure.

Discovery:

- Read current nightly spec list and existing e2e tests.
- Enumerate product areas already covered.
- Explore candidate uncovered areas.
- For each candidate, trace controller/route, service, serializer/envelope, guards, DTOs, seed data, and expected statuses.
- Pick the single highest-value uncovered area.
- If every obvious area is covered, deepen one thin existing spec with a missing edge case.
- If there is genuinely no net-new value, do nothing and report that.

Branch:

- Run `git fetch --all --prune` first.
- Before creating a branch, search open PRs and branches for an existing nightly e2e spec for the same area; if one exists, report it and stop.
- Create a descriptively named branch from `origin/[TRUNK]` only after choosing the area.
- Use a name like `e2e-nightly-<area>`.
- Do not leave work on a random harness branch.

Write:

- Author one `e2e/<spec-name>.spec.ts` matching existing spec style.
- Add seed data only when necessary.
- Keep data idempotent and deterministic.
- Add the spec to every scheduler/list that controls nightly execution.
- Keep all runner lists in sync.

Adversarial verification:

- For every assertion, verify against actual source.
- Remove or fix assertions that do not survive source verification.
- Check route, status, serializer envelope, auth/tenant gate, seed row, and validation behavior.
- Run a completeness critique for missing edge cases.

Validate before commit:

- Run allowed static checks on the new spec.
- Run allowed compile/discovery gate if available.
- Let hooks run.

Rules:

- Use the repo's package manager only.
- Do not deploy.
- Do not touch production.
- Do not run live migrations.
- Do not stage secrets or env files.
- Commit with a clear test-focused message.
- Push and open a PR against `[TRUNK]`.
- Do not merge it.

Report:

- Area added or skip reason.
- Spec filename.
- Test count.
- Verification verdict.
- Runner lists updated.
- Validation performed.
- PR URL.

