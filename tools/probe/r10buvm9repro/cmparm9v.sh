#!/usr/bin/env bash
# vbuvm9 — ONE arm, the OFFICIAL uhdm-cmp both ways: golden vs pristine and
# golden vs patched, in the SAME directory (a UHDM db records absolute paths).
# Head counters read BOTH streams (uhdm-cmp writes the head to STDERR).
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL no uhdm-cmp"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/vbuvm9_cmparm_XXXXXX)
cp "$SRC" "$W/$B.sv"; cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache > sl.log 2>&1
G=slpp_all/surelog.uhdm
if [ ! -f "$G" ]; then printf "%-22s %s\n" "$B" "SURELOG_FAIL wd=$W"; exit 0; fi
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
if [ ! -s p.uhdm ] || [ ! -s q.uhdm ]; then
  printf "%-22s %s\n" "$B" "SLANG_REJECT(p=$([ -s p.uhdm ]&&echo ok||echo no) q=$([ -s q.uhdm ]&&echo ok||echo no)) wd=$W"; exit 0; fi
"$CMP" "$G" p.uhdm > pc.txt 2>&1; prc=$?
"$CMP" "$G" q.uhdm > qc.txt 2>&1; qrc=$?
pl=$(wc -l < pc.txt); ql=$(wc -l < qc.txt)
ph=$(grep -c '^LHS:' pc.txt); qh=$(grep -c '^LHS:' qc.txt)
bytes=IDENTICAL; cmp -s p.uhdm q.uhdm || bytes=MOVED
verdict=SAME
if [ "$ql" -lt "$pl" ]; then verdict=IMPROVED; elif [ "$ql" -gt "$pl" ]; then verdict=WORSE; fi
printf "%-22s cmp %6s -> %-6s heads %s -> %-3s rc %s/%s db=%-9s %s wd=%s\n" \
  "$B" "$pl" "$ql" "$ph" "$qh" "$prc" "$qrc" "$bytes" "$verdict" "$W"
