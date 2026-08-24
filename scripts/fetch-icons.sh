#!/usr/bin/env bash
# Pre-fetch Iconify icons referenced in pages/ into assets/icons/iconify/.
# The template caches icons there at build time; committing them keeps builds
# offline-safe and avoids hammering api.iconify.design on every CI run.
set -euo pipefail
cd "$(dirname "$0")/.."

mapfile -t icons < <(
  grep -rhoE '(icon|figure_icon): *"[a-z0-9-]+:[a-z0-9-]+"' pages _includes 2>/dev/null |
    grep -oE '"[a-z0-9-]+:[a-z0-9-]+"' | tr -d '"' | sort -u
)

for id in "${icons[@]}"; do
  prefix="${id%%:*}"
  name="${id##*:}"
  dest="assets/icons/iconify/$prefix/$name.svg"
  [ -s "$dest" ] && continue
  mkdir -p "$(dirname "$dest")"
  code=$(curl -sS -o "$dest" -w '%{http_code}' "https://api.iconify.design/$prefix/$name.svg")
  if [ "$code" != "200" ] || ! head -c 4 "$dest" | grep -q '<svg'; then
    rm -f "$dest"
    echo "MISSING $id (http $code)" >&2
    exit 1
  fi
  echo "fetched $id"
done
echo "All ${#icons[@]} icons present."
