# toolpkg-gws

`toolpkg-gws` is the Toolbox package repo for the Google Workspace tool package.

The intent is to vendor the real Rust `gws` source into this repo with `git subtree`, then build and publish the Toolbox package from that self-contained source tree.

## Toolbox phase 1

This repo now also carries the first Toolbox-facing package shape:
- `toolbox.pkg.json`
- `tools/users.list.ts`
- a tiny WASI guest under `wasm/gws`

For the current phase, the guest is intentionally simple and prints a fixed JSON
payload for `users list --format json`. The vendored upstream CLI is present for
later work, but is not yet the executable guest.

This guest is built with the Wasmer/Wasix toolchain, not plain `wasm32-wasip1`.
It currently targets Wasix Rust release `v2026-02-09.1+rust-1.90`.

`cargo-wasix` still downloads a custom `wasix` toolchain without `cargo`, so the
build script wraps that downloaded toolchain with the host `cargo` binary before
running the final build.

Build the phase-1 guest with:

```bash
./scripts/build-wasm.sh
```

Current build prerequisites:
- `cargo-wasix` available in `PATH`
- host Rust toolchain available at `~/.rustup/toolchains/1.88.0-x86_64-unknown-linux-gnu`

That writes:

```text
dist/gwc.wasm
```

## Subtree workflow

This repo is expected to track an upstream Rust `gws` repository via `git subtree`, not `git submodule`.

Why:
- the package repo should stay self-contained
- CI/publishing should not depend on submodule checkout behavior
- upstream updates should still be reasonably easy to pull in

Assuming a proficient git user, the intended workflow is:

1. Vendor the upstream source into a dedicated prefix with `git subtree`.
2. Build/package from the vendored source in this repo.
3. Repeat subtree pulls when upstream changes.

The helper script below is now intentionally repo-specific. It just pulls the latest upstream changes from the configured Google Workspace CLI source.

## Helper script

Use [scripts/subtree.sh](scripts/subtree.sh):

```bash
./scripts/subtree.sh
```

Current upstream wiring:

```bash
remote: https://github.com/googleworkspace/cli
branch: main
prefix: upstream/googleworkspace-cli
```

This assumes:
- the upstream repo root is what we want to vendor
- the subtree lives under one stable prefix such as `upstream/googleworkspace-cli`
- we build the Toolbox package from this repo, not from the upstream checkout directly

The upstream source is currently vendored at:

- `upstream/googleworkspace-cli`

## Notes

- Keep local Toolbox/package-specific files outside the subtree prefix where possible.
- If the upstream build needs patching for Toolbox packaging, keep those patches minimal and visible.
- Before expanding subtree automation further, confirm the actual upstream repo URL/branch and target prefix we want to standardize on.
