#!/usr/bin/env bash
set -u
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=/tmp/v73_bnd/probe; STAGE=/tmp/v73_bnd/nstg; mkdir -p "$STAGE"
while read -r rel <&3; do
  key=$(echo "$rel"|tr '/' '_'); key=${key%.sv}; key=${key%.v}
  for view in plain elab; do
    case $view in plain) F="";; elab) F="--elabuhdm";; esac
    for side in N B; do
      case $side in N) BIN=/tmp/v73_bin/neutral.bin;; B) BIN=/tmp/v73_bin/pris.bin;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"; cp "$ROOT/$rel" "$d/"
      b=$(basename "$rel")
      ( cd "$d" && "$BIN" $F "$b" -o slang.uhdm >slang.log 2>&1 </dev/null )
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}_${view}_$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
    done
    if cmp -s "$STAGE/${key}_${view}_N/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then echo "SAME $view $rel"; else echo "DIFF $view $rel"; fi
  done
done 3< /tmp/v73_bnd/WIDE.files
