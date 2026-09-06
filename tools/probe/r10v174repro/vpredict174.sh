#!/usr/bin/env bash
# r10v174repro/vpredict174.sh — the VERIFIER's INDEPENDENT mover prediction.
# MEASUREMENT ONLY.
#
# Made from the PRISTINE databases and their GOLDENS alone — the patched sweep
# is never read.  A database can move under § pkgDefClassCloneNoBitsFold174
# exactly where GOLDEN keeps a type-query `sys_func_call` at a position in a
# PACKAGE DEF listing whose home is an out-of-body (`::`-named) class method,
# and we do NOT.  Those positions are the gate's whole target set, so:
#
#   PREDICTED MOVER  <=>  that set is non-empty
#
# It is a stronger prediction than a constant-shaped scan of our own database
# because it names the CELLS, not just the windows.
#
#   vpredict174.sh <pristine-sweep-workdir> <out.txt>
set -u
WD=$1; OUT=$2
CEN=${CT174CEN:-/tmp/v174_bin/ct174cen}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
[ -x "$CEN" ] || { echo "FATAL: no ct174cen"; exit 3; }
TMP=$(mktemp -d /tmp/v174_pred_XXXXXX)
trap 'rm -rf "$TMP"' EXIT
: > "$OUT"
scanned=0; scanfail=0; predicted=0; windows_only=0
while IFS= read -r c; do
  d=$(dirname "$c")
  rel=${d#"$WD"/}
  ours="$d/slang.uhdm"
  gold=$(grep -oE '/home/[^ )]*slang-uhdm-goldens/[a-f0-9]+' "$c" | head -1)
  [ -n "$gold" ] && gold="$gold/golden.uhdm"
  if [ ! -f "$ours" ] || [ -z "$gold" ] || [ ! -f "$gold" ]; then
    echo "SKIP-NOFILE $rel" >> "$OUT"; continue
  fi
  scanned=$((scanned+1))
  if ! "$CEN" "$ours" > "$TMP/o.txt" 2>/dev/null; then
    echo "SCANFAIL-OURS $rel" >> "$OUT"; scanfail=$((scanfail+1)); continue
  fi
  if ! "$CEN" "$gold" > "$TMP/g.txt" 2>/dev/null; then
    echo "SCANFAIL-GOLD $rel" >> "$OUT"; scanfail=$((scanfail+1)); continue
  fi
  # window = a PKGDEF listing position whose home is an out-of-body class method
  awk -F'\t' '$1=="KEEP" && $2 ~ /^PKGDEF/ && $3 ~ /OOBNAME/ {print $2"|"$3"|"$4"|"$5"|"$6}' "$TMP/g.txt" | sort -u > "$TMP/gk.txt"
  awk -F'\t' '$1=="KEEP" && $2 ~ /^PKGDEF/ && $3 ~ /OOBNAME/ {print $2"|"$3"|"$4"|"$5"|"$6}' "$TMP/o.txt" | sort -u > "$TMP/ok.txt"
  nwin=$(awk -F"\t" '$1=="CONST" && $3 ~ /^PKGDEF/ && $3 ~ /OOBNAME/' "$TMP/o.txt" | wc -l)
  ncell=$(comm -23 "$TMP/gk.txt" "$TMP/ok.txt" | wc -l)
  if [ "$ncell" -gt 0 ]; then
    predicted=$((predicted+1))
    echo "PREDICT-MOVER cells=$ncell ourconsts_in_window=$nwin $rel" >> "$OUT"
  else
    [ "$nwin" -gt 0 ] && windows_only=$((windows_only+1))
    echo "PREDICT-STILL cells=0 ourconsts_in_window=$nwin $rel" >> "$OUT"
  fi
done 3< <(find "$WD" -name cmds.txt | sort) <&3
echo "SCANNED=$scanned PREDICTED_MOVERS=$predicted CONST_IN_WINDOW_BUT_NOT_PREDICTED=$windows_only SCANFAIL=$scanfail" | tee -a "$OUT"
