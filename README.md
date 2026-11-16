# Bitcoin Peer Lab

One Umbrel app for a closer look at your node's peers: **[Peer Lab](https://github.com/benunskilled/peer-lab)**. It requires Umbrel's official **Bitcoin Node** app.

Your node talks to strangers all day. Each one says what software it runs, but is it telling the truth? Peer Lab takes a closer look: what a peer offers, whether it wants your transactions, which chain it is on. A normal node, a wallet, a crawler, or a spy in disguise? The map shows where they are and who hosts them. For every new block it notes which peer brought it first. Slot Fill puts Core's eight empty manual slots to use for spread, and Stratum Race times how fast your own pool turns a new block into fresh work.

**[Try the live demo →](https://peermap.xyz/)**

<img src="./bitcoinlab-peerlab/block-wave.gif" width="900" alt="A new block arrives: an orange wave rolls across the page, the block height goes up by one and the peer that brought it lights up on the map">

## Bitcoin Lab and Peer Map

Peer Lab replaces both. They stay in this store for now but get no new features. Turn off Bitcoin Lab's Slot Fill, or uninstall both, before you install Peer Lab. It keeps the manual peers already set in Core that connect, but starts with its own data; nothing is imported.

## Install

1. In umbrelOS, open **App Store → ⋮ → Community App Stores**.
2. Add this store URL:

   ```text
   https://github.com/benunskilled/bitcoin-lab-community-store
   ```

3. Install **Peer Lab**. Umbrel will offer to install Bitcoin Node first if needed.

Open it from Umbrel, or at `<your-umbrel>:8797`.

## Source and documentation

This repository contains the Umbrel packaging. Application code and detailed documentation live in the app's own repository:

- [Peer Lab](https://github.com/benunskilled/peer-lab) · [Issues](https://github.com/benunskilled/peer-lab/issues) · [Security](https://github.com/benunskilled/peer-lab/blob/main/SECURITY.md)
- [Bitcoin Lab](https://github.com/benunskilled/bitcoin-lab) · [Issues](https://github.com/benunskilled/bitcoin-lab/issues) · [Security](https://github.com/benunskilled/bitcoin-lab/blob/main/SECURITY.md)
- [Peer Map](https://github.com/benunskilled/peer-map) · [Issues](https://github.com/benunskilled/peer-map/issues) · [Security](https://github.com/benunskilled/peer-map/blob/main/SECURITY.md)

For packaging and publishing instructions, see [RELEASING.md](RELEASING.md).
