# Release checklist

For Bitcoin Lab and Peer Map. At most one release per app and week, on Mondays; sooner only if the app is broken,
data is at risk or there is a security issue. Copy this list into the store PR of the release and tick every line.
A line that cannot be ticked stops the release.

## Before tagging

- [ ] Every change since the last release was merged by PR, and Tests on `main` are green, including the test
      against real Bitcoin Core.
- [ ] Independent review: a second reviewer read the whole diff since the last release (`git diff vLAST..main`)
      looking for bugs, wrong claims and risky changes. Every finding is fixed or answered.
- [ ] Release notes written; every statement in them checked against the code or measured data; approved by Ben.
- [ ] `CHANGELOG.md` has the same notes under the new version.
- [ ] Tested on a real Umbrel, both ways:
  - [ ] **Fresh install** of the new version: opens through Umbrel, main function works, restart keeps the data.
  - [ ] **Update** from the version users have now: install that version first, let it collect data and change a
        setting, then update through Umbrel. The app opens, data and settings are still there, logs are clean.
- [ ] Anything else the release changes (compose, permissions, ports, data paths, dependencies) tested on its own.

## Release

- [ ] Version bump merged by PR (Bitcoin Lab: `package.json` + `package-lock.json`); `git log -1` on `main` is that commit.
- [ ] Tag pushed; **Build and publish** workflow green, smoke test included.
- [ ] Provenance checks out: `gh attestation verify oci://ghcr.io/benunskilled/<image>:X.Y.Z --owner benunskilled`.
- [ ] Store PR: image line(s) with the printed reference, `version:`, `releaseNotes:`; **Check apps** green; merged.
- [ ] GitHub Release for the tag with the same notes.

## After

- [ ] The update arrives on the test Umbrel through the store and shows the new version.
- [ ] Local branches cleaned up.
