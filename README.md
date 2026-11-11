# Bitcoin Peer Lab

Two Umbrel apps for a closer look at your node's peers.

| App | What it does |
|---|---|
| [Bitcoin Lab](https://github.com/benunskilled/bitcoin-lab) | Ranks your peers by who brings new blocks first, and fills your manual slots where your node has the fewest connections |
| [Peer Map](https://github.com/benunskilled/peer-map) | Checks what each peer claims against what it really does, and puts them all on a world map. Read-only: it never changes your node |

Use either app on its own or both together. Each requires Umbrel's official **Bitcoin Node** app.

## Bitcoin Lab: who brings blocks first

Every new block reaches your node through one of your peers. Bitcoin Lab notes for every block who was first and ranks your peers by it.

Core has eight manual slots it never fills on its own, so on a default node they sit empty. Slot Fill uses them. It takes peers from Core's own address book and puts them where your node has the fewest connections: other regions and other providers, as far as your node's networks allow. It goes for spread, not speed. It only fills free slots: peers already there stay until they go offline.

Stratum Race times how fast your own pool turns a new block into fresh work, side by side with public solo pools. No miner needed, just a pool app on your Umbrel. Slot Fill and Stratum Race are both off by default.

![Bitcoin Lab dashboard](./bitcoinlab-node/5.png)

## Peer Map: who your node is talking to

Your node talks to strangers all day. Each one says what software it runs, but is it telling the truth? Peer Map takes a closer look: what the peer offers, whether it wants your transactions, how often it pings or asks for addresses, which chain it is on. A normal node, a wallet, a crawler, or a spy in disguise? Find out.

![Peer Map: the map and the start of the Inbound table](./bitcoinlab-peermap/readme.png)

## Better together

With both installed, Peer Map follows every new block across your node: which pool mined it, which of your peers brought it first and, if Stratum Race watches your own pool, roughly how long it took to reach your mining job. Change your setup and you see whether it gets faster.

## No open port?

Both apps still work. Without an open port your node only has the connections it opens itself, plus whatever reaches it over Tor or I2P. Peer Map has fewer strangers to show, but can still catch a surprise in your outbound slots. Bitcoin Lab helps here too: Slot Fill adds up to eight manual peers where your node has the fewest connections.

## Install

1. In umbrelOS, open **App Store → ⋮ → Community App Stores**.
2. Add this store URL:

   ```text
   https://github.com/benunskilled/bitcoin-lab-community-store
   ```

3. Install **Bitcoin Lab**, **Peer Map**, or both. Umbrel will offer to install Bitcoin Node first if needed.

Open the apps from Umbrel, or use their dashboard addresses:

| App | Dashboard |
|---|---|
| Bitcoin Lab | `<your-umbrel>:8790` |
| Peer Map | `<your-umbrel>:8791` |

## Source and documentation

This repository contains the Umbrel packaging. Application code and detailed documentation live in the individual repositories:

- [Bitcoin Lab](https://github.com/benunskilled/bitcoin-lab) · [Issues](https://github.com/benunskilled/bitcoin-lab/issues) · [Security](https://github.com/benunskilled/bitcoin-lab/blob/main/SECURITY.md)
- [Peer Map](https://github.com/benunskilled/peer-map) · [Issues](https://github.com/benunskilled/peer-map/issues) · [Security](https://github.com/benunskilled/peer-map/blob/main/SECURITY.md)

For packaging and publishing instructions, see [RELEASING.md](RELEASING.md).
