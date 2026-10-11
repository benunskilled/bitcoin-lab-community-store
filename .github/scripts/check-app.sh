#!/bin/sh
# Checks one app folder of this store before Umbrel ever sees it:
#   - every image: line in docker-compose.yml is the same reference,
#   - it is ghcr.io/<owner>/<image>:<tag>@sha256:<digest>,
#   - the registry serves that tag publicly, as a multi-arch index with exactly this digest,
#   - the index holds linux/amd64 and linux/arm64,
#   - version: in umbrel-app.yml equals the image tag.
# A wrong digest does not fail loudly on Umbrel: the update hangs in "updating" with no container and no log.
# Usage: .github/scripts/check-app.sh <app-folder>
set -eu
APP="$1"
REFS=$(grep -E '^[[:space:]]*image:' "$APP/docker-compose.yml" | sed -E 's/^[[:space:]]*image:[[:space:]]*//' | sort -u)
[ -n "$REFS" ] || { echo "::error::$APP: no image: line"; exit 1; }
[ "$(echo "$REFS" | wc -l)" -eq 1 ] || { echo "::error::$APP: image: lines differ"; echo "$REFS"; exit 1; }
REF="$REFS"
echo "$REF" | grep -qE '^ghcr\.io/[a-z0-9._/-]+:[A-Za-z0-9._-]+@sha256:[0-9a-f]{64}$' || { echo "::error::$APP: not ghcr.io/<owner>/<image>:<tag>@sha256:<digest>: $REF"; exit 1; }
REPO=$(echo "$REF" | sed -E 's|^ghcr\.io/([^:@]+).*|\1|')
TAG=$(echo "$REF" | sed -E 's|^[^:]+:([^@]+)@.*|\1|')
WANT=$(echo "$REF" | sed -E 's|.*@(sha256:[0-9a-f]{64})$|\1|')
VERSION=$(sed -nE 's/^version:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/p' "$APP/umbrel-app.yml")
[ "$VERSION" = "$TAG" ] || { echo "::error::$APP: version: \"$VERSION\" in umbrel-app.yml but image tag $TAG"; exit 1; }
TOKEN=$(curl -fsS "https://ghcr.io/token?scope=repository:${REPO}:pull&service=ghcr.io" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
ACCEPT="application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json"
BODY=$(curl -fsS -D /tmp/headers -H "Authorization: Bearer $TOKEN" -H "Accept: $ACCEPT" "https://ghcr.io/v2/${REPO}/manifests/${TAG}") \
  || { echo "::error::$APP: $REPO:$TAG not publicly pullable (package private or tag missing)"; exit 1; }
GOT=$(grep -i '^docker-content-digest:' /tmp/headers | awk '{print $2}' | tr -d '\r')
TYPE=$(grep -i '^content-type:' /tmp/headers | awk '{print $2}' | tr -d '\r')
case "$TYPE" in *index*|*manifest.list*) ;; *) echo "::error::$APP: $TAG is not a multi-arch index ($TYPE)"; exit 1;; esac
[ "$WANT" = "$GOT" ] || { echo "::error::$APP: digest $WANT, registry has $GOT for $TAG"; exit 1; }
for arch in amd64 arm64; do
  echo "$BODY" | tr -d ' \n' | grep -q "\"architecture\":\"$arch\",\"os\":\"linux\"" \
    || echo "$BODY" | tr -d ' \n' | grep -q "\"os\":\"linux\",\"architecture\":\"$arch\"" \
    || { echo "::error::$APP: index has no linux/$arch"; exit 1; }
done
echo "$APP: $REPO:$TAG, digest matches, linux/amd64 + linux/arm64, version $VERSION"
