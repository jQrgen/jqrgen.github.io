#!/usr/bin/env bash
# Grep the publishable static site for terms that must not appear.
# The word list lives in this script, which is excluded from the build.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="$(mktemp -d)"
trap 'rm -rf "$dest"' EXIT

while IFS= read -r -d '' file; do
  rel="${file#./}"
  mkdir -p "$dest/$(dirname "$rel")"
  cp "$root/$rel" "$dest/$rel"
done < <(cd "$root" && find . -type f \
  -not -path './.git/*' \
  -not -path './.github/*' \
  -not -path './scripts/*' \
  -print0)

if [[ ! -f "$dest/index.html" ]]; then
  echo "privacy check failed: built site has no index.html" >&2
  exit 1
fi

patterns=(
  "pouch"
  "colectomy"
  "colitis"
  "gastro"
  "ulcerative"
  "ileal"
  "IBD"
  "Crohn"
  "stoma"
  "diagnos"
  "Nordea"
  "DNB"
  "Folio"
  "NOK"
  "org. no."
  "org.nr"
  "919057343"
  "919 057 343"
  "MVA"
  "salary"
  "balance"
)

status=0
for pattern in "${patterns[@]}"; do
  if grep -R -i -n -F -e "$pattern" "$dest"; then
    echo "privacy check failed: found '${pattern}'" >&2
    status=1
  fi
done

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "privacy check passed"
