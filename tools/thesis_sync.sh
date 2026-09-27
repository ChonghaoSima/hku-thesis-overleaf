#!/usr/bin/env bash
# Periodic backup of the thesis to HDFS (permanent storage) and to the
# Overleaf-linked GitHub repository.
#
#   tools/thesis_sync.sh once     run one sync pass now
#   tools/thesis_sync.sh start    start the background daemon (every $THESIS_SYNC_INTERVAL s)
#   tools/thesis_sync.sh stop     stop the daemon
#   tools/thesis_sync.sh status   show daemon state and the last log lines
#
# Environment overrides:
#   THESIS_HDFS_DIR        HDFS mirror root
#   THESIS_SYNC_INTERVAL   seconds between passes (default 1800)
#   THESIS_SYNC_BUILD      1 = compile the PDF before syncing (default 1)
#
# HDFS layout:
#   latest/        rsync mirror of the working tree (no .git, no build/)
#   latest/thesis.pdf
#   repo.bundle    `git bundle --all`, i.e. the full commit history
#   snapshots/     one tar.gz per day, never deleted
#
# Overleaf does not pull from GitHub automatically: in Overleaf use
# Menu -> GitHub -> "Pull GitHub changes into Overleaf" to see new pushes.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SELF="$REPO_DIR/tools/thesis_sync.sh"
HDFS_DIR="${THESIS_HDFS_DIR:-/mnt/hdfs/harunawl/home/byte_data_seed_wl/vlm/iccv/user/smch/hku_thesis_hdfs}"
INTERVAL="${THESIS_SYNC_INTERVAL:-1800}"
BRANCH="main"
STATE_DIR="$HOME/.cache/hku_thesis_sync"
LOG_FILE="$STATE_DIR/sync.log"
PID_FILE="$STATE_DIR/daemon.pid"
LOCK_FILE="$STATE_DIR/sync.lock"

mkdir -p "$STATE_DIR"

log() { echo "[$(date '+%F %T')] $*" >>"$LOG_FILE"; }

build_pdf() {
  command -v latexmk >/dev/null 2>&1 || { log "build: latexmk not found, skipped"; return 0; }
  if bash "$REPO_DIR/tools/build_thesis.sh" >"$STATE_DIR/build.log" 2>&1; then
    log "build: ok"
  else
    log "build: FAILED (see $STATE_DIR/build.log); syncing sources anyway"
  fi
}

sync_hdfs() {
  if [ ! -d "$HDFS_DIR" ]; then
    log "hdfs: target missing: $HDFS_DIR"
    return 1
  fi
  mkdir -p "$HDFS_DIR/latest" "$HDFS_DIR/snapshots"

  rsync -rlt --delete --exclude '.git/' --exclude 'build/' --exclude 'thesis.pdf' \
    "$REPO_DIR/" "$HDFS_DIR/latest/" 2>>"$LOG_FILE" || { log "hdfs: rsync FAILED"; return 1; }

  if [ -f "$REPO_DIR/build/main.pdf" ]; then
    cp -f "$REPO_DIR/build/main.pdf" "$HDFS_DIR/latest/thesis.pdf"
  fi

  if git -C "$REPO_DIR" bundle create "$STATE_DIR/repo.bundle" --all >/dev/null 2>>"$LOG_FILE"; then
    cp -f "$STATE_DIR/repo.bundle" "$HDFS_DIR/repo.bundle"
  fi

  local snap
  snap="$HDFS_DIR/snapshots/hku_thesis_$(date +%Y%m%d).tar.gz"
  if [ ! -f "$snap" ]; then
    tar -czf "$STATE_DIR/snapshot.tar.gz" -C "$(dirname "$REPO_DIR")" \
      --exclude "$(basename "$REPO_DIR")/build" "$(basename "$REPO_DIR")" \
      && cp -f "$STATE_DIR/snapshot.tar.gz" "$snap" \
      && log "hdfs: daily snapshot $(basename "$snap")"
  fi
  log "hdfs: ok"
}

sync_git() {
  cd "$REPO_DIR" || return 1
  git add -A
  if ! git diff --cached --quiet; then
    git commit -q -m "Auto-sync $(date '+%F %T')" && log "git: committed $(git rev-parse --short HEAD)"
  fi

  if ! git fetch -q origin "$BRANCH" 2>>"$LOG_FILE"; then
    log "git: fetch FAILED (is the deploy key added with write access?)"
    return 1
  fi
  # Overleaf may have pushed edits to GitHub; replay local commits on top of them.
  if ! git rebase -q --autostash "origin/$BRANCH" >>"$LOG_FILE" 2>&1; then
    git rebase --abort >/dev/null 2>&1
    log "git: CONFLICT with origin/$BRANCH, push skipped; resolve manually in $REPO_DIR"
    return 1
  fi
  if [ "$(git rev-list --count "origin/$BRANCH..HEAD")" -gt 0 ]; then
    if git push -q origin "HEAD:$BRANCH" 2>>"$LOG_FILE"; then
      log "git: pushed $(git rev-parse --short HEAD)"
    else
      log "git: push FAILED"
      return 1
    fi
  fi
}

run_once() {
  (
    flock -n 9 || { log "skip: another sync pass is running"; exit 0; }
    log "=== sync start ==="
    [ "${THESIS_SYNC_BUILD:-1}" = "1" ] && build_pdf
    sync_hdfs
    sync_git
    log "=== sync end ==="
  ) 9>"$LOCK_FILE"
}

is_running() {
  [ -f "$PID_FILE" ] || return 1
  local pid
  pid="$(cat "$PID_FILE")"
  kill -0 "$pid" 2>/dev/null && tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null | grep -q "thesis_sync.sh _daemon"
}

case "${1:-status}" in
  once)
    run_once
    tail -n 12 "$LOG_FILE"
    ;;
  start)
    if is_running; then
      echo "sync daemon already running (pid $(cat "$PID_FILE")), log: $LOG_FILE"
      exit 0
    fi
    nohup setsid bash "$SELF" _daemon >/dev/null 2>&1 </dev/null &
    sleep 1
    echo "sync daemon started (pid $(cat "$PID_FILE" 2>/dev/null)), every ${INTERVAL}s, log: $LOG_FILE"
    ;;
  _daemon)
    echo $$ >"$PID_FILE"
    log "daemon started (pid $$, interval ${INTERVAL}s)"
    while true; do
      run_once
      sleep "$INTERVAL"
    done
    ;;
  stop)
    if is_running; then
      kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE" && log "daemon stopped" && echo "sync daemon stopped"
    else
      echo "sync daemon not running"
    fi
    ;;
  status)
    if is_running; then
      echo "sync daemon running (pid $(cat "$PID_FILE")), every ${INTERVAL}s"
    else
      echo "sync daemon NOT running (start with: $SELF start)"
    fi
    [ -f "$LOG_FILE" ] && tail -n 15 "$LOG_FILE"
    ;;
  *)
    echo "usage: $0 {once|start|stop|status}" >&2
    exit 2
    ;;
esac
