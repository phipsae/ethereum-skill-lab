#!/usr/bin/env bash
set -euo pipefail

# Allow launching claude from within a Claude Code session
unset CLAUDECODE 2>/dev/null || true

# ─── Config ───────────────────────────────────────────────────────────────────
PROJECT_IDS=("${@:-erc20-staking}")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/../ethskills" && pwd)"
BASE_DIR="$SCRIPT_DIR"
PROMPTS_DIR="$BASE_DIR/prompts"
REPORTS_DIR="$BASE_DIR/reports"
ANVIL_PID=""
FORK_RPC="${FORK_RPC:-https://eth.merkle.io}"
ANVIL_PORT=8545
MODEL="${MODEL:-sonnet}"
BUILDER_MAX_BUDGET="${BUILDER_MAX_BUDGET:-3.00}"
REVIEWER_MAX_BUDGET="${REVIEWER_MAX_BUDGET:-1.00}"

# ─── Helpers ──────────────────────────────────────────────────────────────────
log()  { printf "\033[1;34m[pipeline]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[pipeline]\033[0m %s\n" "$*" >&2; }
die()  { err "$@"; cleanup; exit 1; }
ts()   { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

cleanup() {
  if [[ -n "$ANVIL_PID" ]] && kill -0 "$ANVIL_PID" 2>/dev/null; then
    log "Stopping Anvil (PID $ANVIL_PID)"
    kill "$ANVIL_PID" 2>/dev/null || true
    wait "$ANVIL_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# ─── Pre-flight checks ───────────────────────────────────────────────────────
log "Pre-flight checks..."
MISSING=()
for cmd in forge anvil node npm claude jq; do
  command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done
[[ ${#MISSING[@]} -eq 0 ]] || die "Missing commands: ${MISSING[*]}"

# Validate all project briefs exist before starting
for pid in "${PROJECT_IDS[@]}"; do
  BRIEF="$PROMPTS_DIR/projects/$pid.md"
  [[ -f "$BRIEF" ]] || die "Project brief not found: $BRIEF"
done

log "Projects: ${PROJECT_IDS[*]} | Model: $MODEL"

# ─── Start Anvil ──────────────────────────────────────────────────────────────
log "Starting Anvil (fork: $FORK_RPC)..."
anvil --fork-url "$FORK_RPC" --port "$ANVIL_PORT" --silent &
ANVIL_PID=$!

# Wait for Anvil to be ready (up to 30s)
for i in $(seq 1 30); do
  if cast block-number --rpc-url "http://127.0.0.1:$ANVIL_PORT" &>/dev/null; then
    BLOCK=$(cast block-number --rpc-url "http://127.0.0.1:$ANVIL_PORT" 2>/dev/null)
    log "Anvil ready at block $BLOCK (PID $ANVIL_PID)"
    break
  fi
  [[ $i -eq 30 ]] && die "Anvil failed to start after 30s"
  sleep 1
done

mkdir -p "$REPORTS_DIR"

# ─── Track results across projects ───────────────────────────────────────────
declare -a RESULTS=()

# ─── Per-project loop ─────────────────────────────────────────────────────────
for PROJECT_ID in "${PROJECT_IDS[@]}"; do

  log "════════════════════════════════════════════════════════════════"
  log "Starting project: $PROJECT_ID"
  log "════════════════════════════════════════════════════════════════"

  BUILD_DIR="$BASE_DIR/builds/$PROJECT_ID"
  PROJECT_DIR="$BUILD_DIR/project"
  BRIEF="$PROMPTS_DIR/projects/$PROJECT_ID.md"

  # ─── Clean & prepare ─────────────────────────────────────────────────────────
  log "Cleaning previous build..."
  rm -rf "$BUILD_DIR"
  mkdir -p "$PROJECT_DIR"

  RUN_START=$(ts)

  # ─── Build prompts using temp files (avoids heredoc quoting issues) ──────────
  BUILDER_PROMPT_FILE=$(mktemp)
  REVIEWER_PROMPT_FILE=$(mktemp)

  # Builder prompt: project brief + context
  cat "$BRIEF" > "$BUILDER_PROMPT_FILE"
  cat >> "$BUILDER_PROMPT_FILE" <<EOF

IMPORTANT CONTEXT:
- Anvil is ALREADY running at http://127.0.0.1:${ANVIL_PORT} (forking mainnet). Do NOT start Anvil yourself.
- The skill files are available in the added directory. Read them carefully before each phase.
- Your working directory is the project root. Create contracts/ and frontend/ subdirs as the skill instructs.
- When done (or if you hit a fatal blocker), write your build report to: ${BUILD_DIR}/builder-report.md
EOF

  # Reviewer prompt
  cat > "$REVIEWER_PROMPT_FILE" <<EOF
Review the build at: ${BUILD_DIR}/project/
The builder report is at: ${BUILD_DIR}/builder-report.md
The skill files are in the added skill directory.

IMPORTANT CONTEXT:
- Anvil is ALREADY running at http://127.0.0.1:${ANVIL_PORT} (forking mainnet). You can use cast commands against it.
- Port 3000 is free — you can start the Next.js dev server for frontend smoke testing.

Write your consolidated review to: ${BUILD_DIR}/reviewer-report.md
EOF

  BUILDER_PROMPT=$(<"$BUILDER_PROMPT_FILE")
  BUILDER_SYSTEM=$(<"$PROMPTS_DIR/builder-system.md")
  REVIEWER_SYSTEM=$(<"$PROMPTS_DIR/reviewer-system.md")

  # ─── Agent: Builder ─────────────────────────────────────────────────────────
  log "[$PROJECT_ID] Running builder agent..."
  BUILDER_START=$(ts)
  BUILDER_EXIT=0

  (cd "$PROJECT_DIR" && claude -p "$BUILDER_PROMPT" \
    --append-system-prompt "$BUILDER_SYSTEM" \
    --model "$MODEL" \
    --max-budget-usd "$BUILDER_MAX_BUDGET" \
    --add-dir "$SKILL_DIR" \
    --dangerously-skip-permissions \
    --output-format text) \
    > "$BUILD_DIR/builder-stdout.txt" 2>&1 || BUILDER_EXIT=$?

  BUILDER_END=$(ts)
  log "[$PROJECT_ID] Builder finished (exit code: $BUILDER_EXIT)"

  # Fallback: if builder didn't write a report, create one from stdout
  if [[ ! -f "$BUILD_DIR/builder-report.md" ]]; then
    log "[$PROJECT_ID] No builder report found — generating fallback from stdout"
    {
      printf '# Builder Report (Auto-generated Fallback)\n\n'
      printf 'The builder agent did not produce a structured report. Exit code: %d\n\n' "$BUILDER_EXIT"
      printf '## Raw Output (last 200 lines)\n\n'
      printf '```\n'
      tail -200 "$BUILD_DIR/builder-stdout.txt" 2>/dev/null || printf '(no output captured)\n'
      printf '```\n'
    } > "$BUILD_DIR/builder-report.md"
  fi

  # ─── Agent: Reviewer ───────────────────────────────────────────────────────
  log "[$PROJECT_ID] Running reviewer agent..."
  REVIEWER_START=$(ts)
  REVIEWER_EXIT=0

  REVIEWER_PROMPT=$(<"$REVIEWER_PROMPT_FILE")

  (cd "$BUILD_DIR" && claude -p "$REVIEWER_PROMPT" \
    --append-system-prompt "$REVIEWER_SYSTEM" \
    --model "$MODEL" \
    --max-budget-usd "$REVIEWER_MAX_BUDGET" \
    --add-dir "$SKILL_DIR" \
    --add-dir "$BUILD_DIR" \
    --dangerously-skip-permissions \
    --output-format text) \
    > "$BUILD_DIR/reviewer-stdout.txt" 2>&1 || REVIEWER_EXIT=$?

  REVIEWER_END=$(ts)
  log "[$PROJECT_ID] Reviewer finished (exit code: $REVIEWER_EXIT)"

  # Fallback reviewer report
  if [[ ! -f "$BUILD_DIR/reviewer-report.md" ]]; then
    log "[$PROJECT_ID] No reviewer report found — generating fallback from stdout"
    {
      printf '# Reviewer Report (Auto-generated Fallback)\n\n'
      printf 'The reviewer agent did not produce a structured report. Exit code: %d\n\n' "$REVIEWER_EXIT"
      printf '## Raw Output (last 200 lines)\n\n'
      printf '```\n'
      tail -200 "$BUILD_DIR/reviewer-stdout.txt" 2>/dev/null || printf '(no output captured)\n'
      printf '```\n'
    } > "$BUILD_DIR/reviewer-report.md"
  fi

  # ─── Metadata ───────────────────────────────────────────────────────────────
  RUN_END=$(ts)

  jq -n \
    --arg project "$PROJECT_ID" \
    --arg model "$MODEL" \
    --arg run_start "$RUN_START" \
    --arg run_end "$RUN_END" \
    --arg builder_start "$BUILDER_START" \
    --arg builder_end "$BUILDER_END" \
    --argjson builder_exit "$BUILDER_EXIT" \
    --arg reviewer_start "$REVIEWER_START" \
    --arg reviewer_end "$REVIEWER_END" \
    --argjson reviewer_exit "$REVIEWER_EXIT" \
    '{
      project: $project,
      model: $model,
      run_start: $run_start,
      run_end: $run_end,
      builder: { start: $builder_start, end: $builder_end, exit_code: $builder_exit },
      reviewer: { start: $reviewer_start, end: $reviewer_end, exit_code: $reviewer_exit }
    }' > "$BUILD_DIR/run-meta.json"

  # Symlink latest report
  ln -sf "$BUILD_DIR/reviewer-report.md" "$REPORTS_DIR/latest.md"

  # Clean up temp files
  rm -f "$BUILDER_PROMPT_FILE" "$REVIEWER_PROMPT_FILE"

  RESULTS+=("$PROJECT_ID: builder=$BUILDER_EXIT reviewer=$REVIEWER_EXIT")

  log "[$PROJECT_ID] Done!"
  log "  Builder:  $BUILD_DIR/builder-report.md"
  log "  Reviewer: $BUILD_DIR/reviewer-report.md"
  log "  Meta:     $BUILD_DIR/run-meta.json"

done

# ─── Final summary ──────────────────────────────────────────────────────────
log ""
log "════════════════════════════════════════════════════════════════"
log "All projects complete. Results:"
for r in "${RESULTS[@]}"; do
  log "  $r"
done
log "Latest report: $REPORTS_DIR/latest.md"
log "════════════════════════════════════════════════════════════════"
