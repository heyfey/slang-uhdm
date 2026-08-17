#!/usr/bin/env bash
# VERIFIER wide boundary sweep: EVERY .sv arm under tools/probe/*/ run with BOTH
# binaries (ours only -- no Surelog), o.dump byte-compared after normalising the
# workdir path.  Far wider than vbnd53.sh's 90.
set -u
PAT=${1:?patched}; PRIS=${2:?pristine}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:-/home/heyfey/git-repos/slang-uhdm/tools/probe}
STAGE=/tmp/v53_bnd2; rm -rf "$STAGE"; mkdir -p "$STAGE"
n=0; same=0; diffn=0; noout=0
: > /tmp/v53_bnd2_diff.list
for f in "$ROOT"/*/*.sv $(cd "$(dirname "$0")" && pwd)/*.sv ; do
  [ -e "$f" ] || continue
  n=$((n+1))
  rel=$(echo "$f" | sed "s#$ROOT/##; s#/tmp/wt_v53/tools/probe/##; s#/tmp/v53_arms/#VERIF/#")
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  ok=1
  for side in A B; do
    case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
    d="$STAGE/${key}_$side"; mkdir -p "$d"; cp "$f" "$d/" 2>/dev/null || { ok=0; break; }
    b=$(basename "$f")
    ( cd "$d" && "$BIN" "$b" -o slang.uhdm >slang.log 2>&1 )
    [ -f "$d/slang.uhdm" ] || { ok=0; break; }
    "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}_$side#WD#g" > "$d/o.norm"
    [ -s "$d/o.norm" ] || { ok=0; break; }
  done
  if [ "$ok" = 0 ]; then noout=$((noout+1)); rm -rf "$STAGE/${key}_A" "$STAGE/${key}_B"; continue; fi
  if cmp -s "$STAGE/${key}_A/o.norm" "$STAGE/${key}_B/o.norm"; then
    same=$((same+1)); rm -rf "$STAGE/${key}_A" "$STAGE/${key}_B"
  else
    diffn=$((diffn+1)); echo "$rel" >> /tmp/v53_bnd2_diff.list
  fi
done
echo "WIDE BOUNDARY: total=$n identical=$same DIFFERING=$diffn no_output(unbuildable alone)=$noout"
echo "--- differing arms ---"; cat /tmp/v53_bnd2_diff.list
