#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden and ours under /tmp/v11u483_runs/<case path>/;
# prints rc, uhdm-cmp lines, strict verdict, md5, path-normalised dump distance to golden.
source $(dirname "$0")/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
d(){ $UHDM_DUMP "$1" 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g'; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/v11u483_runs$c; mkdir -p "$W"
  F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv $F -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" $F --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1 | cut -c1-60)
  dist=$(diff <(d $W/sl/slpp_all/surelog.uhdm) <(d $W/$T.uhdm) | grep -c '^[<>]')
  echo "${c#*/cases/} rc=$rc cmp=$n dist=$dist md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8) $st"
done
