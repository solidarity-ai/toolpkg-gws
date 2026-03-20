#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "usage: $0 <add|pull> <remote-url> <branch> <prefix>" >&2
  exit 2
fi

command_name="$1"
remote_url="$2"
branch="$3"
prefix="$4"

remote_name="upstream-$(basename "${remote_url%.git}")"

ensure_remote() {
  if git remote get-url "$remote_name" >/dev/null 2>&1; then
    git remote set-url "$remote_name" "$remote_url"
  else
    git remote add "$remote_name" "$remote_url"
  fi
}

ensure_remote
git fetch "$remote_name" "$branch"

case "$command_name" in
  add)
    git subtree add --prefix="$prefix" "$remote_name" "$branch" --squash
    ;;
  pull)
    git subtree pull --prefix="$prefix" "$remote_name" "$branch" --squash
    ;;
  *)
    echo "unknown command: $command_name" >&2
    exit 2
    ;;
esac
