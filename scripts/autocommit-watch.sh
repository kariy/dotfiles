#!/bin/zsh
set -euo pipefail

REPO="/Users/kariy/dotfiles"
BRANCH="dotfiles"
DEBOUNCE_SECONDS=30
POLL_SECONDS=2
LOCK_DIR="/tmp/dotfiles-autocommit.lock"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
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
  # Build a stable signature from file mtimes + path, excluding .git internals.
  find "$REPO" -type f ! -path "$REPO/.git/*" -print0 \
    | xargs -0 stat -f '%m %N' \
    | LC_ALL=C sort \
    | shasum -a 256 \
    | awk '{print $1}'
}

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
  else
    log "Push failed (commit kept locally). Will retry on next change cycle."
  fi
}

log "Starting dotfiles auto-commit watcher for $REPO"
last_signature="$(snapshot_signature)"
last_change_epoch=0

while true; do
  sleep "$POLL_SECONDS"

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
