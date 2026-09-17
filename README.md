# Bitcoin Peer Lab

Two Umbrel apps: one to see your peers, one to optimise them for fast block
delivery — if you want to.

Your peers are not your choice: Core dials out at random, and whoever else finds
you dials in. Nothing tells you which of them actually delivers a block first.
Bitcoin Lab does, and lets you keep the best ones as manual peers.

- **[Peer Map](https://github.com/benunskilled/peer-map)** — your live peers on
  a world map, split into the manual peers you chose, the outbound peers Core
  picked, and the inbound peers that found you. Each one says what it is — a
  node, a wallet, a crawler — and the ones that cannot pass blocks on are
  crossed out.

- **[Bitcoin Lab](https://github.com/benunskilled/bitcoin-lab)** — which of
  your peers actually delivers each new block first, timed over Core's ZMQ
  interface. It ranks them by how often they win, and you act on that: drop an
  outbound peer that never delivers and Core dials a fresh random one in its
  place straight away. The ones that keep winning move into your eight manual
  slots, which Core never fills by itself.

Use them together or on their own. Neither sends a peer address anywhere.

## Install

1. In umbrelOS: **Settings → App Store → ⋮ → Community App Stores**
2. Add this store:
   ```
   https://github.com/benunskilled/bitcoin-lab-community-store
   ```
3. Install what you want from it. Both apps depend on the official **Bitcoin
   Node** app, which Umbrel offers to install first if you do not have it.

| | Dashboard | Source |
|---|---|---|
| Bitcoin Lab | `<your-umbrel>:8790` | [benunskilled/bitcoin-lab](https://github.com/benunskilled/bitcoin-lab) |
| Peer Map | `<your-umbrel>:8791` | [benunskilled/peer-map](https://github.com/benunskilled/peer-map) |

Bitcoin Lab also has a summary widget for the Umbrel home screen.

![Bitcoin Lab](./bitcoinlab-node/1.png)

![Peer Map](./bitcoinlab-peermap/1.png)

## What this repository is

Packaging only: an `umbrel-app.yml` and a `docker-compose.yml` per app, each
pinned to a multi-arch image by tag **and** digest. The applications themselves
live in their own repositories, linked above.

## Releasing

See [RELEASING.md](./RELEASING.md).
