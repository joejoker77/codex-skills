# Artifacts

Skills and MCP server templates that tenants can be given. This repository is the source of
truth: a timer on each platform host reconciles every tenant against it, and removing something
here removes it from the tenants who had it.

## What is here

    skills/<name>/SKILL.md      prose the agent reads. Prose only — see below.
    commands/<name>.md          a saved prompt a person calls by name
    mcp/<name>.toml             a server definition the runtime connects to

Three kinds, and no others. `subagent`, `workflow` and `plugin` existed on the platform this
replaces; this runtime has nothing to point them at, so they are refused by name rather than
offered as an empty directory that never works.
    mcp/<name>.toml             a fragment of runtime config describing one MCP server.

## What is deliberately NOT here

**Who gets what.** The whitelist lives on each platform host, at
`/etc/codex-fleet/artifacts/tenants.conf`, and is edited by an operator.

That split is the point. This repository is open to contribution — that is what it is for — and a
contribution should be able to add a capability without being able to decide who receives it. An
access decision never arrives through the channel that would grant the access.

## The rules a contribution has to pass

Three gates run on every pull request, and each exists because of a specific way this can go
wrong.

**The scanner.** A skill is prose. An executable inside one is not a skill with a helper attached
— it is the thing a prose-only channel was chosen to prevent, and it is refused by mode bit and
by shebang. Prose that pipes a download into a shell, reaches for credentials, or instructs the
agent to disregard its own instructions is refused too.

MCP templates get three checks that are measured facts about the runtime rather than caution.
Each one fails the same way — the template installs cleanly and the thing silently does not work:

* a marker in `env_http_headers` is read as the *name* of an environment variable, so the header
  is dropped in silence;
* a `${...}` in `env` makes the runtime's config importer drop the whole server;
* a placeholder in `bearer_token_env_var` is a hard start failure.

Put markers in `http_headers`. The proxy replaces them on the way out; the value in this
repository is never a real credential, and no real credential ever belongs in a file here.

**Sensitive paths.** A pull request that touches `.github/` or `ci/` is blocked unless a human
adds the `sensitive-path-approved` label. Those directories are the gates themselves, and a
change that edits its own examiner is the one change that cannot be self-certified.

**Rate limit.** More than five pull requests from one author in a day is blocked, with a
`rate-limit-override` label for the case where it is legitimate. The label matters: a limit with
no way past it gets switched off the first time it is wrong, and then it protects nothing.
