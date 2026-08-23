#!/usr/bin/env bash
# r10vbuvm27 ARM DRIVER — MEASUREMENT ONLY.  Builds golden(Surelog) + pristine +
# patched + fixed for one arm in one view and scores every candidate cell
# four ways with vfour27.py (view-general multiset join on the span).
#   usage: PRI=… PAT=… FIX=… MODE=def|elab ./vscore27.sh <arm.sv>
# BROKE must be 0 for the shipped binary.  golden is ALWAYS the LHS.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?arm}; PRI=${PRI:?}; PAT=${PAT:?}; FIX=${FIX:-}; MODE=${MODE:-def}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
KEY=$(basename "$SRC" .sv)_$MODE
D=${VWD:-/tmp/vbuvm27_armwd}/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC"); cd "$D" || exit 9
fl=""; [ "$MODE" = elab ] && fl=-elabuhdm
"$SURELOG" -parse -nocache $fl "$LEAF" >surelog.log 2>&1 </dev/null
[ -f slpp_all/surelog.uhdm ] || { echo "$KEY SURELOG_FAIL"; exit 5; }
line="$KEY:"
for tag in pris pat fix; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT; [ $tag = fix ] && bin=$FIX
  [ -n "$bin" ] || continue
  "$bin" $fl "$LEAF" -o $tag.uhdm >$tag.log 2>&1 </dev/null; rc=$?
  if [ ! -f $tag.uhdm ]; then line="$line $tag=NO_OUTPUT(rc=$rc)"; continue; fi
  v=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  line="$line $tag=rc$rc/$v/heads$(grep -c '^LHS:' $tag.cmp; true)/lines$(wc -l < $tag.cmp)"
done
echo "$line"
python3 "$HERE/vfour27.py" slpp_all/surelog.uhdm pris.uhdm pat.uhdm ${FIX:+fix.uhdm}
echo "WD=$D" >&2
