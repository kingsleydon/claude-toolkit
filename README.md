# claude-toolkit

A marketplace of custom Claude Code plugins with skills, agents, and utilities.

## Plugins

### claude-toolkit

#### Skills

**[parallel-codex](plugins/claude-toolkit/skills/parallel-codex/SKILL.md)** — Dual-track analysis: dispatches Claude Code and Codex as parallel read-only analysts, then synthesizes a unified recommendation.

- **Trigger words:** `parallel codex`, `dual-track`, `parallel analysis`, `codex analysis`, `let codex check`, `second opinion`, `comparative analysis`, `parallel review`, `dual-track analysis`
- **Requires:** openai/codex plugin installed via marketplace

#### Agents

**[code-reviewer](plugins/claude-toolkit/agents/code-reviewer.md)** — Opinionated code review with structured JSON output:

- Zero tolerance for `as any`, `!` assertions, `@ts-ignore`
- Every async action must have error handling
- All user-facing text must be i18n-wrapped
- Security: input validation, no exposed internals, escaped queries
- Flag code duplication (3+ occurrences)
- Structured JSON output with severity, confidence, and rule classification ([schema](plugins/claude-toolkit/schemas/review-output.schema.json))

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
