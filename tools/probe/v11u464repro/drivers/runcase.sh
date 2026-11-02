#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden (probe args) and ours (probe args)
# under /tmp/v11u464_runs/<case path>/; prints rc, uhdm-cmp lines, strict verdict, md5.
# A case dir with a FILES file passes those files (in that order) to both tools.
source $(dirname "$0")/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  W=/tmp/v11u464_runs$c; mkdir -p "$W"
  newer=0; for f in $F; do [ "$c/$f" -nt "$W/sl/slpp_all/surelog.uhdm" ] && newer=1; done
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ $newer = 1 ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv $F -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" $F --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  if [ -f "$W/$T.uhdm" ]; then
    n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
    st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
    d=$(bash $(dirname "$0")/dist.sh "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm")
    m=$(md5sum < "$W/$T.uhdm" | cut -c1-8)
  else n=-; st=NO_DB; d=-; m=-; fi
  echo "${c#*/cases/} rc=$rc cmp=$n dist=$d $st md5=$m"
done
