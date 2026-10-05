#!/bin/bash
# v11u239: mktree.sh <sweep root> <tree root>: a symlink tree of every sweep database, the path list built and
# filtered by $FENCED (word boundary) BEFORE any database is opened; probe databases become <case>/slang.uhdm.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "mktree: FENCED unset" >&2; exit 2; }
src=$1; dst=$2; [ -d "$src" ] && [ -n "$dst" ] || exit 2
FRE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
(cd "$src" && find . -name '*.uhdm' -type f) | grep -vE "$FRE" | grep -v '/build/' | while read -r p; do
  case "$p" in ./probe/*) q="${p%.uhdm}/slang.uhdm";; *) q="$p";; esac
  mkdir -p "$dst/$(dirname "$q")"; ln -sf "$src/${p#./}" "$dst/$q"
done
