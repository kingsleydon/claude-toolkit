# claude-toolkit

A marketplace of custom Claude Code plugins with skills, agents, and utilities.

## Plugins

### claude-toolkit

#### Skills

**[parallel-codex](plugins/claude-toolkit/skills/parallel-codex/SKILL.md)** — Parallel dual-track analysis mode that runs Claude Code and OpenAI Codex simultaneously for read-only analysis, then synthesizes findings before executing.

- **Trigger words:** `parallel codex`, `dual-track`, `parallel analysis`, `second opinion`, `parallel review`
- **Prerequisites:** [Codex CLI](https://github.com/openai/codex) (`npm i -g @openai/codex`) — works without Codex in degraded mode (Claude Code only).

#### Agents

**[code-reviewer](plugins/claude-toolkit/agents/code-reviewer.md)** — Opinionated code review agent enforcing strict quality standards:

- Zero tolerance for `as any`, `!` assertions, `@ts-ignore`
- Every async action must have error handling
- All user-facing text must be i18n-wrapped
- Security: input validation, no exposed internals, escaped queries
- Flag code duplication (3+ occurrences)
- Fix pre-existing issues in touched files

#### Extras

**[statusline](plugins/claude-toolkit/extras/statusline/)** — Custom statusline showing directory, git branch, model, and context usage with color coding.

See [statusline.sh](plugins/claude-toolkit/extras/statusline/statusline.sh) for installation instructions.

## Installation

```
/plugin marketplace add kingsleydon/claude-toolkit
/plugin install claude-toolkit@kingsleydon-claude-toolkit
```

## License

MIT
