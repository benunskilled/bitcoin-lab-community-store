# Bitcoin Lab — Umbrel Community App Store

This repository is the Umbrel Community App Store that installs **Bitcoin Lab**:
peer relay ranking and mining-pool latency racing, built for solo miners.

It contains only the packaging — `umbrel-app.yml` and `docker-compose.yml`. The
application itself, and everything about how it works, lives in
[**benunskilled/bitcoin-lab**](https://github.com/benunskilled/bitcoin-lab).

![Bitcoin Lab dashboard](./bitcoinlab-node/1.png)

## Install

1. In Umbrel: **Settings → App Store → ⋮ → Community App Stores**
2. Add this store's URL:
   ```
   https://github.com/benunskilled/bitcoin-lab-community-store
   ```
3. Open the **Bitcoin Lab** store and install **Bitcoin Lab**. It depends on the
   official **Bitcoin Node** app, which Umbrel offers to install first if you do
   not already have it.

The dashboard is then at `<your-umbrel>:8788`, and a summary widget is available
for the Umbrel home screen.

## Releasing

See [RELEASING.md](./RELEASING.md).
