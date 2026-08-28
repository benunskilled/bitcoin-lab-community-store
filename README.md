# Bitcoin Lab — Umbrel Community App Store

Personal Umbrel Community App Store that publishes **Bitcoin Lab**: a peer
relay performance profiler + stratum race for Bitcoin Core nodes.

The actual application source code and Docker image live in the separate
[`bitcoin-lab`](https://github.com/<github-user>/bitcoin-lab) repository.
This repo only contains the Umbrel packaging (`umbrel-app.yml` +
`docker-compose.yml`) that tells Umbrel how to install and run it.

## One-time setup

1. **Create the `bitcoin-lab` source repo** on GitHub (public, so `docker
   build-push-action` and Umbrel's image pull can both reach it) and push
   the contents of the sibling `bitcoin-lab/` folder to it.
2. **Tag a release** to trigger the multi-arch image build:
   ```sh
   git -C bitcoin-lab tag v1.0.0
   git -C bitcoin-lab push --tags
   ```
   Watch the "Build and publish multi-arch image" GitHub Action run to
   completion. Its last step prints the exact
   `ghcr.io/<owner>/bitcoin-lab:1.0.0@sha256:<digest>` reference.
3. **Paste that reference** into all four `image:` lines in
   `bitcoinlab-node/docker-compose.yml` (replacing
   `sha256:REPLACE_AFTER_FIRST_RELEASE`).
4. **Replace every `<github-user>` placeholder** in this repo
   (`bitcoinlab-node/umbrel-app.yml`: `website`, `repo`, `support`, `icon`)
   and in `bitcoin-lab/.github/workflows/release.yml` is already dynamic
   (uses `github.repository_owner`), so nothing to change there.
5. **Make the GHCR image public.** By default a package pushed by CI is
   private to your account - open
   `https://github.com/users/<github-user>/packages/container/bitcoin-lab/settings`
   and set visibility to Public, otherwise Umbrel cannot pull it.
6. **Push this repo** (`bitcoin-lab-community-store`) to GitHub as well.
7. In the Umbrel UI: **Settings → App Store → Community App Stores → Add
   App Store**, paste this repo's GitHub URL, then install "Bitcoin Lab"
   from the "Bitcoin Lab" store like any other app. It will prompt you to
   install the official **Bitcoin Node** app first if you haven't already
   (declared as a `dependencies:` requirement).

## Updating later

Bump `version:` in `bitcoinlab-node/umbrel-app.yml`, write `releaseNotes:`,
tag+push a new version in `bitcoin-lab`, and update the four `image:`
digests here the same way. Umbrel will then show an available update for
installs using this store.
