# claude-skills

A collection of custom Claude Code skills for enhanced development workflows.

## Skills

### parallel-codex

Parallel dual-track analysis mode that runs Claude Code and OpenAI Codex simultaneously for read-only analysis, then synthesizes findings from both before executing any changes.

**Trigger words:** `parallel codex`, `dual-track`, `parallel analysis`, `second opinion`, `parallel review`

**Prerequisites:** [Codex CLI](https://github.com/openai/codex) (`npm i -g @openai/codex`) — the skill degrades gracefully if Codex is not installed.

## Installation

Add this plugin to Claude Code:

```bash
/plugin marketplace add kingsleydon/claude-skills
/plugin install claude-skills
```

## License

MIT
