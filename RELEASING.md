# Releasing

Two repositories move together: [`bitcoin-lab`](https://github.com/benunskilled/bitcoin-lab)
holds the application and publishes the image, this one tells Umbrel how to
install it.

**The `version:` in `bitcoinlab-node/umbrel-app.yml` always equals the version in
the application's `package.json`.** Umbrel shows that field as the installed
version, so any other number misleads the user. A change to the store page alone
— text or screenshots — gets no version of its own: Umbrel re-reads the store on
every refresh.

## Steps

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
   `ghcr.io/benunskilled/bitcoin-lab:X.Y.Z@sha256:<digest>` reference.

Here:

7. Set the same `version:`, rewrite `description:` if the app changed, and write
   `releaseNotes:` for people rather than as a changelog — one paragraph, what
   changed and why it matters. Look at what other Umbrel apps do: descriptions
   there run about 200 words in three paragraphs, release notes one paragraph.
8. Paste the pinned reference into **all four** `image:` lines in
   `bitcoinlab-node/docker-compose.yml`. Tag *and* digest — a moving tag would
   mean two nodes installing "the same version" get different code.
9. Commit and push. Umbrel offers the update on the next store refresh.
10. Back in `bitcoin-lab`, publish a GitHub Release for the tag with the same
    notes. The workflow does not do this. Releases start at v1.13.0; earlier
    tags have none, so refer to those by version rather than linking.

## Screenshots

`bitcoinlab-node/1.png` … `4.png` are the store gallery, and `1.png` is also the
header image of the application README.

- **1.png** — the page from the top through the Live Peer Ranking
- **2.png** — the Peer Rotation card, including the rotation log
- **3.png** — the Stratum Race card
- **4.png** — the Storage card

All four are 1280 CSS px wide at 2× scale, so 2560 px, from the same seeded demo
data — only RFC 5737 documentation addresses, never a real peer. Regenerate them
in the app repo:

```sh
npm install --no-save playwright     # not a dependency: the app never needs a browser
DATA_DIR=/tmp/bitcoin-lab-demo node scripts/seed-demo-data.js
MOCK_RPC_PORT=18332 node scripts/mock-rpc-server.js &
DATA_DIR=/tmp/bitcoin-lab-demo BITCOIN_RPC_HOST=127.0.0.1 \
  BITCOIN_RPC_PORT=18332 node src/dashboard-server.js &
DATA_DIR=/tmp/bitcoin-lab-demo node scripts/screenshot.js
```

`screenshot.js` refreshes the demo heartbeats first, so the picture does not show
the "3 background services are not reporting in" banner — that banner is true of
a demo stack running no workers and false of the app, and it has shipped in a
store screenshot once already.

**Changing dashboard text means changing a screenshot.** The rotation card's
explanatory paragraphs are in 2.png; the storage panel's are in 4.png. A text
edit without a new picture puts a UI in the store that no longer exists.
