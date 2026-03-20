#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
crate_dir="$repo_root/wasm/gws"
output_dir="$repo_root/dist"
tooling_dir="$repo_root/.tooling/wasix"
rustup_home="$tooling_dir/rustup-home"
wasix_data_dir="$tooling_dir/data"
wasix_cache_dir="$tooling_dir/cache"
host_toolchain_path="${HOME}/.rustup/toolchains/1.88.0-x86_64-unknown-linux-gnu"
wasix_release="v2026-02-09.1+rust-1.90"
wrapped_wasix_toolchain="$tooling_dir/wasix-toolchain"

mkdir -p "$output_dir"

if ! command -v cargo-wasix >/dev/null 2>&1; then
  echo "cargo-wasix is required in PATH" >&2
  exit 1
fi

if [[ ! -x "$host_toolchain_path/bin/cargo" ]]; then
  echo "expected host cargo toolchain at $host_toolchain_path" >&2
  exit 1
fi

rm -rf "$rustup_home" "$wrapped_wasix_toolchain"
mkdir -p "$rustup_home" "$wasix_data_dir" "$wasix_cache_dir"

RUSTUP_HOME="$rustup_home" rustup toolchain link toolbox-host "$host_toolchain_path"
RUSTUP_HOME="$rustup_home" rustup default toolbox-host >/dev/null

RUSTUP_HOME="$rustup_home" \
WASIX_DATA_DIR="$wasix_data_dir" \
WASIX_CACHE_DIR="$wasix_cache_dir" \
cargo wasix download-toolchain "$wasix_release" >/dev/null

mkdir -p "$wrapped_wasix_toolchain"
cp -a "$wasix_data_dir/toolchains/x86_64-unknown-linux-gnu_${wasix_release}/rust/." "$wrapped_wasix_toolchain/"
ln -sf "$host_toolchain_path/bin/cargo" "$wrapped_wasix_toolchain/bin/cargo"

RUSTUP_HOME="$rustup_home" rustup toolchain link wasix "$wrapped_wasix_toolchain"

(
  cd "$crate_dir"
  RUSTUP_HOME="$rustup_home" \
  WASIX_DATA_DIR="$wasix_data_dir" \
  WASIX_CACHE_DIR="$wasix_cache_dir" \
  cargo wasix build --release
)

cp \
  "$crate_dir/target/wasm32-wasmer-wasi/release/gws_guest.wasi.wasm" \
  "$output_dir/gwc.wasm"
