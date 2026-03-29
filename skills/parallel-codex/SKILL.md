---
name: parallel-codex
description: |
  Parallel dual-track analysis mode: Claude Code and Codex perform read-only analysis simultaneously,
  then synthesize findings from both before executing.
  Trigger words: "parallel codex", "dual-track", "parallel analysis", "codex analysis", "let codex check",
  "second opinion", "comparative analysis", "parallel review", "dual-track analysis"
allowed-tools: Read, Grep, Glob, Write, Task, Bash(codex:*), Bash(cat:*), Bash(ls:*), Bash(tree:*), Bash(tail:*), Bash(wait:*), Bash(kill:*), Bash(mkdir:*), Bash(echo:*), Bash(rm:*), Bash(wc:*)
---

# Parallel Codex — Dual-Track Analysis → Synthesis → Execution

## Workflow

```
         User submits task
              │
    ┌─────────┴─────────┐
    ▼                   ▼
 Claude Code          Codex
 read-only analysis  read-only analysis
 (via Explore        (codex exec
  subagent)           -s read-only)
    │                   │
    └─────────┬─────────┘
              ▼
       Claude Code Synthesis
       Compare findings from both,
       produce unified analysis report
              │
              ▼
       Claude Code Review
       Confirm plan, fill in gaps
              │
              ▼
       Claude Code Execution
       Implement final plan
```

## Phase 0: Pre-flight Check

Verify Codex CLI is available before starting:

```bash
codex --version 2>/dev/null || echo "CODEX_NOT_INSTALLED"
```

If output is `CODEX_NOT_INSTALLED`, inform the user:
> Codex CLI is not installed. Please run `npm i -g @openai/codex` to install, then retry.

Then complete analysis and execution using Claude Code alone (degraded mode).

## Phase 1: Parallel Read-Only Analysis

### 1a. Construct Codex analysis prompt and launch in background

Based on the user's task, construct a targeted analysis prompt, write it to a temp file, then launch Codex in the background.

```bash
mkdir -p /tmp/parallel-codex
SESSION_ID="$(date +%s)-$(openssl rand -hex 4)"
echo "$SESSION_ID" > /tmp/parallel-codex/current-session

cat > /tmp/parallel-codex/prompt-${SESSION_ID}.md << 'PROMPT_EOF'
You are a senior code analyst. Perform a read-only analysis of the current project. Do not modify any files.

## Analysis Task

[Fill in based on the user's specific question — be concrete and specific]

## Output your analysis in the following structure

### 1. Current State Assessment
- Relevant code files and their responsibilities
- Pros and cons of the current implementation

### 2. Recommended Approach
- Recommended solution and rationale
- Alternative approaches
- Tradeoffs for each approach

### 3. Risks and Edge Cases
- Potential bugs and edge cases
- Performance risks
- Security concerns
- Compatibility issues

### 4. Implementation Suggestions
- Recommended order of changes
- Dependencies to be aware of
- Suggested test cases
PROMPT_EOF

codex exec \
  -s read-only \
  - < /tmp/parallel-codex/prompt-${SESSION_ID}.md \
  -o /tmp/parallel-codex/codex-result-${SESSION_ID}.md \
  2>/tmp/parallel-codex/codex-stderr-${SESSION_ID}.log &

echo $! > /tmp/parallel-codex/pid-${SESSION_ID}
```

**Key rules:**
- Do not pass `-m` unless the user explicitly specifies a model
- Always use `-s read-only`
- Use `-o` to output to a file, redirect stderr to a log

### 1b. Claude Code performs read-only analysis concurrently

While Codex runs in the background, Claude Code also performs read-only analysis on the same problem:

- Use read-only tools: Read, Grep, Glob, etc.
- Read relevant source files
- Understand code structure and dependencies
- Form independent analysis conclusions

**Important: Claude Code must NOT perform any write operations during Phase 1.**

Hold Claude Code's analysis conclusions in memory, pending merge with Codex results.

## Phase 2: Synthesize Both Analyses

### 2a. Read Codex analysis results

```bash
SESSION_ID=$(cat /tmp/parallel-codex/current-session)

# Wait for Codex to finish (up to 5 minutes)
if [ -f /tmp/parallel-codex/pid-${SESSION_ID} ]; then
  CODEX_PID=$(cat /tmp/parallel-codex/pid-${SESSION_ID})
  WAIT_COUNT=0
  while kill -0 $CODEX_PID 2>/dev/null; do
    sleep 5
    WAIT_COUNT=$((WAIT_COUNT + 1))
    if [ $WAIT_COUNT -ge 60 ]; then
      echo "CODEX_TIMEOUT"
      kill $CODEX_PID 2>/dev/null
      break
    fi
  done
fi

# Read results
if [ -f /tmp/parallel-codex/codex-result-${SESSION_ID}.md ]; then
  cat /tmp/parallel-codex/codex-result-${SESSION_ID}.md
else
  echo "CODEX_NO_OUTPUT"
  cat /tmp/parallel-codex/codex-stderr-${SESSION_ID}.log 2>/dev/null | tail -20
fi
```

### 2b. Output synthesized analysis report

Compare both analyses and present to the user in this format:

```
## Dual-Track Analysis Report

### Consensus Findings
- [Issues and approaches both sides agree on]

### Claude Code Unique Findings
- [Things Claude found that Codex did not mention]

### Codex Unique Findings
- [Things Codex pointed out that Claude missed]

### Points of Divergence
- [Areas where the two disagree, with rationale from each]

### Synthesized Recommendation
- [Optimal approach after combining both analyses]
- [Key risks to watch for]
- [Implementation steps]
```

## Phase 3: Review + Confirmation

After presenting the synthesized report, **wait for user confirmation** before executing:

> Above is the synthesized conclusion from dual-track analysis. I will proceed with the recommended plan once you confirm.
> Would you like to adjust anything, or shall I execute?

## Phase 4: Execution

After user confirmation, execute according to the synthesized plan:
- Modify code
- Run tests
- Output change summary

## Phase 5: Cleanup

```bash
SESSION_ID=$(cat /tmp/parallel-codex/current-session 2>/dev/null)
if [ -n "$SESSION_ID" ]; then
  rm -f /tmp/parallel-codex/prompt-${SESSION_ID}.md
  rm -f /tmp/parallel-codex/codex-result-${SESSION_ID}.md
  rm -f /tmp/parallel-codex/codex-stderr-${SESSION_ID}.log
  rm -f /tmp/parallel-codex/pid-${SESSION_ID}
  rm -f /tmp/parallel-codex/current-session
fi
```

## Degraded Mode Handling

| Scenario | Action |
|----------|--------|
| Codex not installed | Claude Code analysis only; prompt user to install Codex |
| Codex timeout | Continue with Claude Code results; note Codex timed out |
| Codex output empty | Check stderr log, report error, continue execution |
| Codex auth expired | Prompt user to run `codex auth`; continue with Claude Code only |
