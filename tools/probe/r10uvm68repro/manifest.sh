#!/usr/bin/env bash
# r10uvm68 — the MANIFEST: every file in this directory, what it is, and whether
# it RUNS (a driver) or is DATA (an arm source) or is a RECORD (the README).
# A directory whose write-up cites a script that is not here is the campaign's
# most-repeated failure; this prints the list so the citation can be checked.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
cd "$HERE" || exit 9
printf '%-22s %-8s %s\n' FILE KIND WHAT
while IFS= read -r f; do
  case "$f" in
    *.sv)  k=ARM ;;
    *.sh)  k=DRIVER ;;
    *.py)  k=DRIVER ;;
    *.md)  k=RECORD ;;
    *)     k=OTHER ;;
  esac
  d=$(sed -n '2,6p' "$f" 2>/dev/null | sed -n 's/^[#/ ]*//p' | head -1)
  printf '%-22s %-8s %s\n' "$f" "$k" "${d:0:80}"
done < <(ls -1 | grep -v '^__pycache__$')
