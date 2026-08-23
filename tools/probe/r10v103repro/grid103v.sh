#!/usr/bin/env bash
# r10v103repro/grid103v.sh — build one arm's THREE databases (golden Surelog,
# binary A, binary B) in BOTH views and dump them.  MEASUREMENT ONLY; the
# official uhdm-cmp / verify_golden.py remain the only judges.
#   grid103v.sh <file.sv> <binA> <binB> <workdir>
# Every command is echoed with its rc into <workdir>/cmds.txt so the binary each
# database came from is auditable BY PATH, and a rc=139 can never read as a
# result.  Children get </dev/null.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1 </dev/null; echo "rc=$? $1" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for t in "g_$v/slpp_all/surelog.uhdm:G.$v" "a_$v.uhdm:A.$v" "b_$v.uhdm:B.$v"; do
    f=${t%%:*}; tag=${t#*:}
    if [ -s "$W/$f" ]; then
      uhdm-dump "$W/$f" 2>&1 </dev/null | sed "s#$W/##g; s#$(dirname "$SV")/##g" > "$W/dump.$tag.txt"
      echo "dump rc=$? $f -> dump.$tag.txt" >> "$W/cmds.txt"
    else : > "$W/dump.$tag.txt"; echo "dump MISSING $f" >> "$W/cmds.txt"; fi
  done
done
wc -l "$W"/dump.*.txt
