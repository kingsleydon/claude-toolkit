---
name: parallel-codex
description: |
  Parallel dual-track analysis mode: Claude Code and Codex perform read-only analysis simultaneously,
  then synthesize findings from both before executing.
  Trigger words: "parallel codex", "dual-track", "parallel analysis", "codex analysis", "let codex check",
  "second opinion", "comparative analysis", "parallel review", "dual-track analysis"
allowed-tools: Read, Grep, Glob, Write, Agent, Bash(cat:*), Bash(ls:*)
---

# Parallel Codex — Dual-Track Analysis

<purpose>
Run Claude Code and Codex as independent analysts on the same task, then synthesize
a unified recommendation before touching any code.
</purpose>

<prerequisites>
This skill requires the official `openai/codex` plugin to be installed.
If not installed, inform the user and fall back to Claude Code-only analysis.
</prerequisites>

## Workflow

```
       User submits task
            │
  ┌─────────┴─────────┐
  ▼                   ▼
Claude Code         Codex
(Explore agent)     (codex:rescue agent)
read-only           read-only
  │                   │
  └─────────┬─────────┘
            ▼
     Synthesize findings
            │
            ▼
     User confirms plan
            │
            ▼
     Execute changes
```

## Phase 1: Parallel Read-Only Analysis

Launch both analyses concurrently using the Agent tool in a single message:

<agent_dispatch>

**Agent A — Claude Code Explore:**
- Use `subagent_type: Explore` with thoroughness "very thorough"
- Prompt: the user's task framed as a read-only analysis question
- Tools: Read, Grep, Glob only — no writes

**Agent B — Codex Rescue:**
- Use `subagent_type: codex:codex-rescue`
- Prompt: the same task, prefixed with "Perform read-only analysis only. Do not modify files."
- Let the official codex plugin handle CLI invocation, auth, and cleanup

Both agents MUST be dispatched in the same message for true parallelism.
</agent_dispatch>

<write_guard>
Write and Edit tools are ONLY permitted after user confirmation in Phase 3.
During Phases 1-2, all analysis is strictly read-only.
</write_guard>

## Phase 2: Synthesize

After both agents return, compare their findings and present:

<output_format>
## Dual-Track Analysis Report

### Consensus
- [Findings both sides agree on]

### Claude Code Only
- [Unique findings from Claude Code]

### Codex Only
- [Unique findings from Codex]

### Divergence
- [Disagreements with rationale from each side]

### Recommendation
- [Unified approach combining the best of both]
- [Key risks]
- [Implementation order]
</output_format>

## Phase 3: Confirm + Execute

Present the report and wait for user confirmation before making any changes.

After confirmation, execute according to the synthesized plan.
