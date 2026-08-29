# Bitcoin Lab — Umbrel Community App Store

**Bitcoin Lab** turns your Bitcoin Core node's peer connections *and* mining-pool
connections into measurable numbers instead of guesswork.

![Bitcoin Lab dashboard](./bitcoinlab-node/1.png)

## What it does

- **Peer relay ranking** — continuously tracks which of your connected peers
  actually deliver new blocks first, over Bitcoin Core's ZMQ interface. Builds
  up a long-term First / Eligible / First % ranking per peer, plus ping,
  session count and total connection time, so you can see which peers are
  actually worth keeping as manual connections instead of guessing.
- **Stratum Race** — races your mining pools against each other on every new
  block template (any local solo pool you add by host/port, plus a handful of
  public solo pools out of the box), tracking wins, win %, and latency
  (avg/median/P90) per pool. Because every pool is timed the same way on the
  same event, this is what makes it possible to see **whether a pool switch,
  or a network/config change, actually made things faster — in numbers,** not
  just a feeling.

Both live on the same dashboard, refreshed continuously.

## Installing

1. In Umbrel: **Settings → App Store → ⋮ → Community App Stores**
2. Paste this store's URL:
   ```
   https://github.com/benunskilled/bitcoin-lab-community-store
   ```
3. Open the **Bitcoin Lab** store and install **Bitcoin Lab**. It depends on
   the official **Bitcoin Node** app, which Umbrel will offer to install
   first if you don't already have it.

The dashboard is then reachable at `<your-umbrel>:8788`.

## Repositories

- [`bitcoin-lab`](https://github.com/benunskilled/bitcoin-lab) — the
  application source and the Docker image it publishes.
- `bitcoin-lab-community-store` (this repo) — only the Umbrel packaging
  (`umbrel-app.yml` + `docker-compose.yml`) that tells Umbrel how to install
  and update it.

---

## Maintainer notes (updating a release)

1. Bump `version:` in `bitcoinlab-node/umbrel-app.yml`, write `releaseNotes:`.
2. Tag and push a new version in `bitcoin-lab` (`git tag vX.Y.Z && git push --tags`)
   and wait for the "Build and publish multi-arch image" GitHub Action to
   finish — its last step prints the exact
   `ghcr.io/benunskilled/bitcoin-lab:X.Y.Z@sha256:<digest>` reference.
3. Paste that reference into all four `image:` lines in
   `bitcoinlab-node/docker-compose.yml`.
4. Commit and push this repo. Umbrel shows the update to anyone who has
   already added this store; a store that's never been added before will
   see the current version right away.

A packaging-only change (no new application image) can bump just this repo's
`version:` — the `image:` digests stay pointed at whatever release is
current.
