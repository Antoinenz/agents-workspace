# agents-workspace

This is a private workspace for agents (cloud-based Claude Code sessions,
etc.) to host, interact with, and store data that's also accessible to
the user — across many small, unrelated projects over time.

> ⚠️ **Keep this repository private.** It accumulates personal
> information over time (`resources/about-you.md`, whatever gets dropped
> into project folders). If you set this up from a template, double-check
> the repo's visibility is set to Private before putting anything real
> into it.

- **Agents:** read [`CLAUDE.md`](./CLAUDE.md) first, every session.
- Projects live under [`projects/`](./projects/), one folder each.
- [`PROJECTS.md`](./PROJECTS.md) is the index of what exists and its status.
- [`resources/`](./resources/) holds reference material shared across
  all projects (writing style, standing facts/preferences about the user).
- [`scripts/`](./scripts/) has `sync.sh` and `new-project.sh` so syncing
  and creating a project are one command each.
