# Releasing

Three repositories move together. [`bitcoin-lab`](https://github.com/benunskilled/bitcoin-lab)
and [`peer-map`](https://github.com/benunskilled/peer-map) hold the two
applications and publish their images; this one tells Umbrel how to install
them. Half the store is Peer Map, so it has a procedure here too — it is the
same shape as Bitcoin Lab's, with one image reference instead of four.

**The `version:` in each `umbrel-app.yml` always equals the version the
application was built with.** For Bitcoin Lab that is the version in its
`package.json`; for Peer Map there is no manifest file — the version is the git
tag, baked into the binary at build time with `-X main.Version=` and reported by
`peermap version`, which the release workflow checks against the tag before it
lets the release stand. Umbrel shows that field as the installed version, so any
other number misleads the user. A change to the store page alone — text or
screenshots — gets no version of its own: Umbrel re-reads the store on every
refresh.

## What the workflows do on a tag

Both application repositories now work the same way, and it is worth knowing
before you push a tag, because it changed after Peer Map v0.8.0 published with a
red test run beside it:

- **Build and publish multi-arch image** (`release.yml`) triggers on `v*.*.*`.
- Its first job calls the whole **Tests** workflow (`ci.yml`) and the publish job
  is `needs:`-gated on it. Everything Tests runs has to pass before anything is
  pushed: unit tests, `go vet`/`gofmt` or `npm test`, the both-architecture image
  build (Peer Map), and the regtest integration test, which is gated on a tag ref
  and so runs on a release.
- Only then does the publish job build and push `:X.Y.Z` and `:latest`, smoke-test
  the pushed image on the architectures it publishes, and print the pinned
  reference.
- `ci.yml` no longer triggers on tags by itself. On a tag it runs once, inside
  the release.

So: a red check now means nothing was published. Before, it meant a coin flip.

## Bitcoin Lab

In `bitcoin-lab`:

1. Make the code changes. Update `README.md` if behaviour or wording changed,
   and bump the `?v=` stamp on its screenshot URL if the picture changed.
2. `npm test` — all green.
3. Bump `package.json` (and `package-lock.json`), commit.
4. **Check `git log -1` before tagging.** A failed commit still leaves `git tag`
   working, and the tag then lands on the previous version's code — which the
   workflow will happily build and publish under the new number.
5. `git tag vX.Y.Z`, then `git push origin master:main` and `git push origin vX.Y.Z`.
6. Wait for the **Build and publish multi-arch image** workflow. Its last step,
   *Print pinned reference for the app package*, prints the exact
   `ghcr.io/benunskilled/bitcoin-lab:X.Y.Z@sha256:<digest>` reference. Copy the
   whole line, not just the hash: the repository also publishes one manifest per
   architecture, and their digests look identical but are not the one to pin.
   **Verify it before it goes anywhere** — see *Checking a digest* below.

Here:

7. Set the same `version:` in `bitcoinlab-node/umbrel-app.yml`, rewrite
   `description:` if the app changed, and write `releaseNotes:` for people
   rather than as a changelog — one paragraph, what changed and why it matters.
   Look at what other Umbrel apps do: descriptions there run about 200 words in
   three paragraphs, release notes one paragraph.
8. Paste the pinned reference into **all four** `image:` lines in
   `bitcoinlab-node/docker-compose.yml` — dashboard, peer-profiler,
   relay-profiler and stratum-race all run the same image. Tag *and* digest: a
   moving tag would mean two nodes installing "the same version" get different
   code.
9. Commit and push. Umbrel offers the update on the next store refresh.
10. Back in `bitcoin-lab`, publish a GitHub Release for the tag with the same
    notes. The workflow does not do this. Releases start at v1.13.0; earlier
    tags have none, so refer to those by version rather than linking.

## Peer Map

Same shape, fewer moving parts: one service, one `image:` line, no `package.json`
to bump.

In `peer-map`:

1. Make the code changes. `gofmt -w .`, then `go vet ./...` and `go test ./...`
   — the release gate runs all three and `gofmt` is part of it.
2. **Check `git log -1` before tagging**, for the same reason as above.
3. `git tag vX.Y.Z`, then push the branch and the tag.
4. Wait for **Build and publish multi-arch image**. It gates on the full Tests
   workflow, then builds `linux/amd64,linux/arm64` with `VERSION=X.Y.Z`, pushes
   `:X.Y.Z` and `:latest`, and smoke-tests **both** architectures: each image
   must print `X.Y.Z` for `peermap version` and answer `peermap healthcheck`
   within 30 seconds. Its last step prints
   `ghcr.io/benunskilled/peer-map:X.Y.Z@sha256:<digest>`.
   Verify that digest — see below.

Here:

5. Set the same `version:` in `bitcoinlab-peermap/umbrel-app.yml` and write
   `releaseNotes:`. If the release depends on a Bitcoin Lab version — as 0.8.0's
   green and orange rows depend on Bitcoin Lab 1.23.0 — say so in the notes;
   nothing in the packaging enforces it, and `dependencies:` lists only Umbrel's
   `bitcoin` app.
6. Paste the pinned reference into the single `image:` line in
   `bitcoinlab-peermap/docker-compose.yml`.
7. Commit and push.
8. Back in `peer-map`, publish a GitHub Release for the tag if the change is
   worth one. The workflow does not do this either.

The two apps release independently. Only the release notes tie a Peer Map
version to a Bitcoin Lab version.

## Checking a digest before pinning

The reference printed by the workflow comes from `docker/build-push-action`'s
own output. Three checks, in this order, before it goes into a compose file.
Substitute `bitcoin-lab` or `peer-map` for `<app>`:

1. **Ask the registry what the tag resolves to**, and compare it with the
   printed digest:

   ```sh
   TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:benunskilled/<app>:pull&service=ghcr.io" \
     | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
   curl -sI -H "Authorization: Bearer $TOKEN" \
     -H "Accept: application/vnd.oci.image.index.v1+json" \
     "https://ghcr.io/v2/benunskilled/<app>/manifests/X.Y.Z" \
     | grep -i docker-content-digest
   ```

   That prints the digest of the multi-arch index, which is what belongs in the
   compose file.

2. **Pull it by digest on the node itself**, on the machine that will run it:

   ```sh
   docker pull ghcr.io/benunskilled/<app>:X.Y.Z@sha256:<digest>
   ```

   A reference that cannot be resolved fails here, in a shell, with a message —
   rather than in Umbrel, silently.

3. **Look at what was pulled**:

   ```sh
   docker manifest inspect ghcr.io/benunskilled/<app>:X.Y.Z@sha256:<digest>
   ```

   It must be an OCI image index listing **both** `linux/amd64` and
   `linux/arm64`. A single-architecture manifest passes checks 1 and 2 and then
   fails on somebody's Raspberry Pi.

Pinning the wrong digest does not fail loudly: Docker cannot resolve the
reference, the update hangs before a single container is created, the app's logs
stay empty because there is no container to log, and Umbrel sits in
`"state": "updating"` until the manifest is corrected and the update is
triggered again. That cost an evening once.

## Screenshots

Bitcoin Lab's gallery in `bitcoinlab-node/umbrel-app.yml` is **five** files,
`1.png` … `5.png`:

- **1.png** — the page from the top through the Live Peer Ranking
- **2.png** — the Peer Rotation card, including the rotation log
- **3.png** — the Stratum Race card
- **4.png** — the Storage card
- **5.png** — also used as the Bitcoin Lab header image in this repository's
  `README.md`

`bitcoinlab-node/overview.png` is a sixth file and not part of the gallery: it is
the header image of the *application* repository's `README.md`, which is where
its `?v=` stamp gets bumped.

Peer Map's gallery is two files, `bitcoinlab-peermap/1.png` and `2.png`, and
`1.png` is also the Peer Map header image in this repository's `README.md`.

Captures come from the app repo's `scripts/screenshot.js`, which takes **one**
full-page screenshot of the dashboard at a 1280 CSS px viewport and writes it to
`$SCREENSHOT_OUT` (default `/tmp/bitcoin-lab-screenshot-full.png`). The numbered
gallery files are cut from that capture by hand — no script in either repository
crops or numbers them — and the blur numbers in `tools/blur-addresses.py` are
written for a 2940 px-wide capture (a MacBook at 2×) and scaled to the actual
width of whatever picture it is given, so a capture at a different scale still
blurs correctly.

Regenerate a capture in the app repo:

```sh
npm install --no-save playwright     # not a dependency: the app never needs a browser
DATA_DIR=/tmp/bitcoin-lab-demo node scripts/seed-demo-data.js
MOCK_RPC_PORT=18332 node scripts/mock-rpc-server.js &
DATA_DIR=/tmp/bitcoin-lab-demo BITCOIN_RPC_HOST=127.0.0.1 \
  BITCOIN_RPC_PORT=18332 node src/dashboard-server.js &
DATA_DIR=/tmp/bitcoin-lab-demo node scripts/screenshot.js
```

The demo data uses only RFC 5737 documentation addresses, never a real peer.
`tools/blur-addresses.py` is here for the other case: given a picture and the
pixel coordinates of an address column, it makes that text unreadable with the
same Gaussian blur every store picture uses.

`screenshot.js` refreshes the demo heartbeats first, so the picture does not show
the "3 background services are not reporting in" banner — that banner is true of
a demo stack running no workers and false of the app, and it has shipped in a
store screenshot once already.

**Changing dashboard text means changing a screenshot.** The rotation card's
explanatory paragraphs are in 2.png; the storage panel's are in 4.png. A text
edit without a new picture puts a UI in the store that no longer exists.
