# Agent instructions — agents-workspace

This repo is a shared, always-on workspace for agent sessions (Claude Code,
cloud sessions, etc.) working alongside the user across many small,
unrelated projects over time. There is one working copy and one `main`
branch — no per-project branches or worktrees. Isolation between projects
is achieved purely by **folder convention** plus the discipline below, not
by git branching.

Read this whole file before doing anything else in this repo.

---

> ⚠️ **Privacy comes first.** This repo accumulates personal information
> over time — `resources/about-you.md`, whatever gets dropped into
> project folders, progress logs. It must stay a **private** repository.
> If you're able to check (e.g. `gh repo view --json isPrivate`), verify
> this early in a session and tell the user immediately and unmissably
> if it's ever public — don't bury that in the middle of a long reply.
> Don't assume the user has read this file, either: if there's any sign
> they might not have (fresh clone, unfamiliarity with the setup), say
> the private-repo requirement out loud rather than filing it away as
> something only you saw. The same goes for any other repo-hygiene issue
> that could quietly bite the user later.

---

## 0. Every session starts with a sync

Before reading or writing anything else:

```
scripts/sync.sh   # or: git pull --rebase --autostash
```

Do this even if you think the tree is clean — other agents (or the user,
elsewhere) may have pushed since you last looked. If this repo isn't
cloned yet, clone it first.

## 1. Opening a session

If the user's first message doesn't already name a specific project or
task, don't assume — greet them briefly, ask how they're doing and what
they'd like help with today. While you do that (or right after), read
`PROJECTS.md` to see what's already in flight so you can offer it back to
them, e.g. "you've got 'q3-budget-model' in progress, last touched 3 days
ago, still on that or something new?"

It's also worth a quick read of `resources/about-you.md` early on — it
holds standing preferences/facts that apply across every project, so you
don't re-ask things a previous session already learned. Treat it as a
living template: it will often be empty or partly filled in (especially
right after this repo was first set up), and that's expected, not a
problem to fix in one go.

If the `Name` field is still `_not set_`, it's worth asking for it early
— just once, low-key, and clearly optional (e.g. "what should I call
you, if you don't mind sharing?"). Don't push if they'd rather not say;
just leave it `_not set_` and move on.

If it's missing something, don't interrogate the user to complete it all
at once. Ask at most one or two short questions per turn, only about
whatever's actually relevant to what you're doing right now (e.g. ask
about writing tone when you're about to draft something for them, not on
an unrelated coding task). Skip it entirely if nothing in the current
task touches a gap. If you have a structured choice tool available (e.g.
Claude Code's option-picker), prefer it over open-ended free text —
answering "pick one of these" is less effort than composing a reply.
Whatever the user tells you, write it into `about-you.md` yourself,
replacing the placeholder, and commit it along with your other changes —
don't just hold it in-session. Never guess or infer an answer to fill a
gap yourself; leave it as `_not set_` until the user actually says.

Only create a new project folder once you know what the task actually is.
Never create a placeholder/empty project "just in case."

## 2. Resume vs. new project

Before creating a new folder:

1. Check `PROJECTS.md` (the registry) for a project that already matches
   what the user is describing.
2. If one exists, `cd` into `projects/<slug>/`, read `PROGRESS.md` and
   `README.md` there, and resume from that state instead of starting over.
3. Only if nothing matches, create a new project (see §3).

This is the whole point of the registry: an agent that starts cold should
never duplicate work another agent already started.

## 3. Creating a new project

```
scripts/new-project.sh <slug> ["one-line summary"]
```

This copies `projects/_TEMPLATE/`, stamps `README.md`/`PROGRESS.md`,
adds a row to `PROJECTS.md`, and commits + pushes it — all in one step,
so it can't be done inconsistently. Result:

```
projects/<slug>/
  README.md      # what this project is / goal / any constraints
  PROGRESS.md    # dated log — see format below
  resources/     # inputs the user drops in for you to read
  output/        # things you fetch, generate, or produce
```

- `<slug>` is short kebab-case, e.g. `2026-08-27-tax-return` or
  `garden-irrigation-plan`. Prefix with the creation date if the name
  alone could plausibly collide with a future unrelated project.
- Push happens *before* asking the user to hand over resources — that
  way the folder exists remotely for them to drop files into (see §5 for
  how they'll actually do that).
- If you can't run the script for some reason, do the same steps
  manually: copy `projects/_TEMPLATE/`, fill in `README.md`/
  `PROGRESS.md`, add a row to `PROJECTS.md` (see §8), commit, push.

## 4. Shared resources (`resources/`)

Separate from any one project: `resources/` at the repo root holds
reference material useful across projects — style guides, checklists,
reusable templates. See `resources/README.md` for what's there. Check it
when it's plausibly relevant (e.g. writing prose meant to sound like the
user, not an AI) — it's a "consult when it makes sense" shelf, not a
mandatory checklist, and it grows over time as things get added.

## 5. Getting resources from the user

You will often need the user to hand you files — a spreadsheet, slides,
photos, a PDF — that are too big or numerous to paste inline. Don't
assume you share a filesystem with them: this session might be a cloud
agent with no local disk the user can drop files onto, or the user might
not have (or want to use) an inline-attachment channel at all.

The reliable, channel-independent way to hand off files in this repo is
**the user adding them directly to `projects/<slug>/resources/` via the
GitHub web UI** (the "Add file → Upload files" button on that folder, or
however else they choose to commit them) and then telling you they've
pushed. When you ask the user for resources, say so explicitly and give
them the exact path — don't just say "attach it here" or "drop it on
disk" and leave the delivery mechanism to their imagination.

Once they say they've sent something:

1. **Pull first** (`scripts/sync.sh`) before you look at anything on
   disk. A check that runs before syncing will reliably show nothing,
   even when the user really did push — that's not evidence the upload
   failed.
2. Only if the files are genuinely still missing *after* a fresh pull
   should you tell the user and ask them to double check where/whether
   they pushed.

This isn't limited to the initial handoff — any time you're blocked
waiting on the user to add or change something in the repo, re-sync
before concluding it isn't there.

## 6. Working inside a project

- Stay inside your project's own folder. Don't edit files under another
  project's `projects/<slug>/` unless the user explicitly asks you to
  cross-reference or move something.
- Put anything the user hands you, or that you fetch from the web/APIs/
  other tools, under that project's `resources/` (their inputs) or
  `output/` (your outputs) — don't scatter files at the repo root. The
  one exception is genuinely cross-project reference material, which
  belongs in the shared `resources/` from §4 instead.
- Keep secrets, API keys, and credentials out of the repo entirely, even
  inside a project folder. This workspace is synced and persistent.

## 7. Progress log format (`PROGRESS.md`)

Append, don't rewrite history. Newest entry on top. Each entry:

```
## 2026-08-27 — <agent/session identifier if known>
Status: active | blocked | done
- what you did this turn
- what you learned / decided
- what's left / next step for whoever picks this up next
```

Keep `README.md` for the stable description of the project; keep
`PROGRESS.md` for the running diary. Someone (human or agent) should be
able to read just the top entry of `PROGRESS.md` and know exactly where
things stand.

## 8. `PROJECTS.md` registry

One row per project, kept current. Update it whenever you create a
project or change its status:

```
| Project | Status | Last updated | Summary |
```

Status values: `active`, `blocked`, `done`, `paused`.

## 9. Ending a turn — commit and push

If you changed, fetched, or generated anything, commit and push before
ending your turn. Don't leave work sitting only in the local working
copy.

```
git add projects/<slug>/ PROJECTS.md   # scope the add to what you touched
git commit -m "<slug>: <short summary of what changed>"
git pull --rebase --autostash
git push
```

- Pull-rebase again right before the push in case someone else pushed
  while you were working — resolve trivially (different folders almost
  never conflict) and retry the push.
- Never `git push --force` / `--force-with-lease` to `main` without the
  user explicitly asking for it.
- Don't bundle unrelated projects into one commit — if you touched two
  projects in one turn, commit them separately with their own messages.
- It's fine (expected) to commit and push multiple times within a single
  turn if it's a long one — don't hoard uncommitted work.

## 10. Ground rules

- No separate workspaces/worktrees/branches per project — folder
  isolation only. This keeps `git pull`/`push` simple for every agent.
- If you genuinely need a conflicting change to another project's files,
  say so and ask the user rather than silently editing it.
- Prefer small, frequent commits over one giant commit at the end.
- If `git push` is rejected, `git pull --rebase --autostash` and retry —
  don't overwrite remote history.
- A GitHub Action (`.github/workflows/checks.yml`) scans every push for
  committed secrets and checks that every `projects/` folder has a
  `PROJECTS.md` row. It runs *after* the push (there's no review gate
  here), so treat a failure as "go fix this now," not as something that
  blocked anything.
