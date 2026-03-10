#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH="dotfiles"
DEBOUNCE_SECONDS=30
POLL_SECONDS=2
LOCK_DIR="/tmp/dotfiles-autocommit.lock"
LOG_FILE="${LOG_FILE:-/tmp/dotfiles-autocommit.log}"
MAX_LOG_SIZE=$((1024 * 1024))  # 1MB
MAX_PUSH_RETRIES=5

push_failures=0

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

rotate_log() {
  if [[ -f "$LOG_FILE" ]] && [[ "$(wc -c < "$LOG_FILE")" -gt "$MAX_LOG_SIZE" ]]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
    log "Log rotated."
  fi
}

cleanup() {
  rm -rf "$LOCK_DIR"
}

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "Another watcher is already running; exiting."
  exit 0
fi
trap cleanup EXIT INT TERM

if [[ ! -d "$REPO/.git" ]]; then
  log "Repository not found at $REPO"
  exit 1
fi

if ! git -C "$REPO" config user.name >/dev/null || ! git -C "$REPO" config user.email >/dev/null; then
  log "Git identity is missing (user.name/user.email); exiting."
  exit 1
fi

snapshot_signature() {
  git -C "$REPO" status --porcelain 2>/dev/null | sha256sum | awk '{print $1}'
}

# sha256sum is not available on macOS by default, use shasum -a 256 instead
if ! command -v sha256sum >/dev/null 2>&1; then
  sha256sum() { shasum -a 256 "$@"; }
fi

is_repo_busy() {
  [[ -f "$REPO/.git/index.lock" ]] \
    || [[ -d "$REPO/.git/rebase-apply" ]] \
    || [[ -d "$REPO/.git/rebase-merge" ]] \
    || [[ -f "$REPO/.git/MERGE_HEAD" ]] \
    || [[ -f "$REPO/.git/CHERRY_PICK_HEAD" ]] \
    || [[ -f "$REPO/.git/REVERT_HEAD" ]]
}

commit_and_push() {
  if is_repo_busy; then
    log "Repository is in the middle of another git operation; skipping this cycle."
    return
  fi

  git -C "$REPO" add -A

  if git -C "$REPO" diff --cached --quiet; then
    log "No staged changes to commit."
    return
  fi

  local msg
  msg="chore(dotfiles): auto-commit $(date '+%Y-%m-%d %H:%M:%S')"

  if git -C "$REPO" commit -m "$msg"; then
    log "Committed changes: $msg"
  else
    log "Commit failed; keeping watcher alive."
    return
  fi

  if git -C "$REPO" push origin "$BRANCH"; then
    log "Pushed commit to origin/$BRANCH"
    push_failures=0
  else
    push_failures=$((push_failures + 1))
    if [[ "$push_failures" -ge "$MAX_PUSH_RETRIES" ]]; then
      log "Push failed $push_failures times in a row; giving up. Commits are kept locally."
      push_failures=0
    else
      log "Push failed (attempt $push_failures/$MAX_PUSH_RETRIES). Will retry on next change cycle."
    fi
  fi
}

log "Starting dotfiles auto-commit watcher for $REPO"
last_signature="$(snapshot_signature)"
last_change_epoch=0
cycles_since_rotation=0

while true; do
  sleep "$POLL_SECONDS"

  # Rotate log periodically (every ~5 minutes)
  cycles_since_rotation=$((cycles_since_rotation + 1))
  if (( cycles_since_rotation >= 150 )); then
    rotate_log
    cycles_since_rotation=0
  fi

  current_signature="$(snapshot_signature)"
  if [[ "$current_signature" != "$last_signature" ]]; then
    last_signature="$current_signature"
    last_change_epoch="$(date +%s)"
    log "Detected filesystem change."
    continue
  fi

  if [[ "$last_change_epoch" -eq 0 ]]; then
    continue
  fi

  now_epoch="$(date +%s)"
  if (( now_epoch - last_change_epoch >= DEBOUNCE_SECONDS )); then
    commit_and_push
    last_signature="$(snapshot_signature)"
    last_change_epoch=0
  fi
done
