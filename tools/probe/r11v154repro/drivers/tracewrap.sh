#!/bin/bash
LAWBIN=/tmp/v11u154_bin/fix1.bin; CENLOG=/tmp/v11u154_cen/census.log
o=""; prev=""; for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
mkdir -p /tmp/v11u154_cen; e=$(mktemp /tmp/v11u154_cen/e.XXXXXX)
R11U154_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^R11U154_TRACE ' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^R11U154_TRACE ' "$e" >&2; rm -f "$e"; exit $rc
