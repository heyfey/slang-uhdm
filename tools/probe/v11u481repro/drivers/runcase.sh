#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden (check_probe.py's flags) and ours
# (dut.sv --single-unit --nobuiltin) under /tmp/v11u481_runs/<full case path>/;
# prints exit code, uhdm-cmp lines, strict verdict, path-normalized dump distance to golden,
# import-copy role mismatches (rolecmp onlyO) and md5 of ours.  Explicit case DIRECTORIES only.
source ${ENVFILE:-/tmp/v11u481_env.sh} || exit 1
B=$1; T=$2; shift 2
RC=${ROLECMP:-/tmp/v11u481_none}
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
[ -x "$SURELOG" ] && [ -x "$UHDM_CMP" ] && [ -x "$UHDM_DUMP" ] && [ -x "$STRICTCMP" ] || { echo "tool missing"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/v11u481_runs$c; mkdir -p "$W"
  newest=$(ls -t "$c"/*.sv* | head -1)
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$newest" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
    $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed -E 's#[^ ,:]*/##g' > "$W/sl.dump"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  $UHDM_DUMP "$W/$T.uhdm" 2>/dev/null | sed -E 's#[^ ,:]*/##g' > "$W/$T.dump"
  dd=$(diff "$W/sl.dump" "$W/$T.dump" | grep -c '^[<>]')
  ro=$([ -x "$RC" ] && $RC "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" | sed 's/.*onlyO=//')
  echo "${c#*/cases/} $T rc=$rc cmp=$n $st dd=$dd roles=$ro md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
