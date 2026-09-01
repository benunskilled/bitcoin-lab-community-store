# Releasing

Two repositories move together: [`bitcoin-lab`](https://github.com/benunskilled/bitcoin-lab)
holds the application and publishes the image, this one tells Umbrel how to
install it.

## Version policy

**The `version:` in `bitcoinlab-node/umbrel-app.yml` always equals the version
in the application's `package.json`.** Umbrel shows that field as the installed
app version, so any other number is a lie to the user — for a while this store
was on 1.12.19 while the app running on people's nodes was 1.12.8.

A change to the store page alone (description, screenshots, release notes) does
not get a version of its own. Umbrel re-reads the store on every refresh, so the
new text appears without one; only a new application build changes the number.

## Steps

1. In `bitcoin-lab`: bump `package.json`, commit, `git tag vX.Y.Z`, push the
   branch and the tag.
2. Wait for the **Build and publish multi-arch image** workflow. Its final step
   prints the exact `ghcr.io/benunskilled/bitcoin-lab:X.Y.Z@sha256:<digest>`
   reference. (It can also be read from the GitHub Packages API, which is
   useful when the workflow logs are not reachable.)
3. Here: set the same `version:`, write `releaseNotes:` for people rather than
   for a changelog, and paste that pinned reference into all four `image:` lines
   in `bitcoinlab-node/docker-compose.yml`.
4. Commit and push. Umbrel offers the update to anyone who has added this store;
   a node adding it for the first time sees the current version immediately.
5. In `bitcoin-lab`, publish a GitHub Release for the tag using the same notes,
   so the history is readable outside Umbrel too.

## Screenshots

`bitcoinlab-node/1.png` .. `3.png` are the store gallery, and `1.png` is also
the header image of both READMEs. They are regenerated from the demo stack:

```sh
DATA_DIR=/tmp/bitcoin-lab-demo node scripts/seed-demo-data.js
MOCK_RPC_PORT=18332 node scripts/mock-rpc-server.js &
DATA_DIR=/tmp/bitcoin-lab-demo BITCOIN_RPC_HOST=127.0.0.1 \
  BITCOIN_RPC_PORT=18332 node src/dashboard-server.js &
node scripts/screenshot.js
```

**When a screenshot changes, bump the `?v=` on the image URL in
`bitcoin-lab/README.md`.** The file name stays the same forever, so browsers
and GitHub's CDN happily keep serving the old picture to anyone who has
already seen it - the version stamp is what makes the URL new.

## Notes

- The image must be pinned by tag **and** digest. A moving tag would mean two
  nodes installing "the same version" could get different code.
- This repository is not tagged. The manifest's `version:` is the record.
