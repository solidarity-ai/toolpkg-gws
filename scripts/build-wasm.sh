#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
crate_dir="$repo_root/wasm/gws"
target_dir="$repo_root/target"
output_dir="$repo_root/dist"

mkdir -p "$output_dir"

mise exec rust@stable -- rustup target add wasm32-wasip1 >/dev/null
mise exec rust@stable -- cargo build \
  --manifest-path "$crate_dir/Cargo.toml" \
  --target wasm32-wasip1 \
  --release \
  --target-dir "$target_dir"

cp \
  "$target_dir/wasm32-wasip1/release/gws_guest.wasm" \
  "$output_dir/gws.wasm"
