#!/usr/bin/env bash
set -euo pipefail

remote_name="upstream-cli"
remote_url="https://github.com/googleworkspace/cli"
branch="main"
prefix="upstream/googleworkspace-cli"

ensure_remote() {
  if git remote get-url "$remote_name" >/dev/null 2>&1; then
    git remote set-url "$remote_name" "$remote_url"
  else
    git remote add "$remote_name" "$remote_url"
  fi
}

ensure_remote
git fetch "$remote_name" "$branch"
git subtree pull --prefix="$prefix" "$remote_name" "$branch" --squash
