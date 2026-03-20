# toolpkg-gws

`toolpkg-gws` is the Toolbox package repo for the Google Workspace tool package.

The intent is to vendor the real Rust `gws` source into this repo with `git subtree`, then build and publish the Toolbox package from that self-contained source tree.

## Subtree workflow

This repo is expected to track an upstream Rust `gws` repository via `git subtree`, not `git submodule`.

Why:
- the package repo should stay self-contained
- CI/publishing should not depend on submodule checkout behavior
- upstream updates should still be reasonably easy to pull in

Assuming a proficient git user, the intended workflow is:

1. Add the upstream remote once.
2. Pull the upstream source into a dedicated prefix with `git subtree`.
3. Build/package from the vendored source in this repo.
4. Repeat subtree pulls when upstream changes.

The helper script below wraps the common commands.

## Helper script

Use [scripts/subtree.sh](scripts/subtree.sh):

```bash
./scripts/subtree.sh add <remote-url> <branch> <prefix>
./scripts/subtree.sh pull <remote-url> <branch> <prefix>
```

Current upstream wiring:

```bash
./scripts/subtree.sh add https://github.com/googleworkspace/cli main upstream/googleworkspace-cli
./scripts/subtree.sh pull https://github.com/googleworkspace/cli main upstream/googleworkspace-cli
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
