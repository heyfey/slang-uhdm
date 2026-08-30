#!/usr/bin/env bash
# v102 WIDE BOUNDARY worker: one source file, both views, both frozen binaries.
set -u
f=$1
PAT=/tmp/v102_pat.bin; PRIS=/tmp/v102_pris.bin
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=/tmp/v102_probe_stage
STAGE=/tmp/v102_widest
rel=${f#$ROOT/}
key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
for view in plain elab; do
  case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
  ok=1
  for side in A B; do
    case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
    d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
    cp "$f" "$d/" 2>/dev/null || { ok=0; continue; }
    b=$(basename "$f")
    ( cd "$d" && "$BIN" $FLAGS "$b" -o slang.uhdm >slang.log 2>&1 </dev/null )
    rc=$?
    echo "$rc $side $view $rel" >> $STAGE/rc.$$
    [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
    "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}_${view}_$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
    [ -s "$d/o.norm" ] || ok=0
  done
  if [ "$ok" = 0 ]; then echo "NOOUT $view $rel" >> $STAGE/res.$$; rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue; fi
  if cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
    echo "SAME $view $rel" >> $STAGE/res.$$; rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
  else
    echo "DIFF $view $rel" >> $STAGE/res.$$
  fi
done
echo "PROCESSED $rel" >> $STAGE/proc.$$
