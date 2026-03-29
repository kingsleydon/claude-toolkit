# claude-toolkit

A collection of custom Claude Code skills, agents, and utilities for enhanced development workflows.

## Components

### Skills

#### [parallel-codex](skills/parallel-codex/SKILL.md)

Parallel dual-track analysis mode that runs Claude Code and OpenAI Codex simultaneously for read-only analysis, then synthesizes findings from both before executing changes.

**Trigger words:** `parallel codex`, `dual-track`, `parallel analysis`, `second opinion`, `parallel review`

**Prerequisites:** [Codex CLI](https://github.com/openai/codex) (`npm i -g @openai/codex`) — degrades gracefully if not installed.

### Agents

#### [code-reviewer](agents/code-reviewer.md)

Opinionated code review agent that enforces strict quality standards:

- Zero tolerance for `as any`, `!` assertions, `@ts-ignore`
- Every async action must have error handling
- All user-facing text must be i18n-wrapped
- Security: input validation, no exposed internals, escaped queries
- Flag code duplication (3+ occurrences → extract utility)
- Fix pre-existing issues in touched files

### Extras

#### [statusline](extras/statusline/)

Custom Claude Code statusline script showing:
- Current directory (shortened)
- Git branch
- Model name
- Context window usage with color coding (green → yellow → red)

See [statusline.sh](extras/statusline/statusline.sh) for installation instructions.

## Installation

Install as a Claude Code plugin:

```
/plugin marketplace add kingsleydon/claude-toolkit
/plugin install claude-toolkit
```

> **Note:** The `extras/` directory contains standalone utilities that need manual setup — see each extra's own instructions.

## License

MIT
