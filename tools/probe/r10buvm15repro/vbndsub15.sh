#!/usr/bin/env bash
# vbuvm15 VERIFIER boundary gate — buvm13's bndsub13.sh, carried forward with its
# fd-3 fix intact and its workdir renamed so it cannot collide with another
# pass's.  List of ABSOLUTE arm sources on STDIN.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
same=0; moved=0; rej=0; one=0; seen=0
while read -r src <&3; do
  [ -f "$src" ] || { echo "FATAL: no such arm source: $src (pass ABSOLUTE paths)"; exit 8; }
  seen=$((seen+1))
  key=$(echo "$src" | sed 's#.*/probe/##; s#/#_#g; s#\.sv$##')
  W=/tmp/vbuvm15_bnd_$key
  rm -rf "$W"; mkdir -p "$W" || exit 3
  cp "$src" "$W/a.sv"
  (cd "$W" && "$PRISTINE" a.sv -o p.uhdm >p.log 2>&1 </dev/null)
  (cd "$W" && "$PATCHED"  a.sv -o q.uhdm >q.log 2>&1 </dev/null)
  if [ ! -f "$W/p.uhdm" ] && [ ! -f "$W/q.uhdm" ]; then
    printf "%-58s %-10s %s\n" "$key" - REJECT-BOTH; rej=$((rej+1)); continue; fi
  if [ ! -f "$W/p.uhdm" ] || [ ! -f "$W/q.uhdm" ]; then
    printf "%-58s %-10s %s\n" "$key" - "ONE-SIDE-ONLY(REGRESSION)"; one=$((one+1)); continue; fi
  if cmp -s "$W/p.uhdm" "$W/q.uhdm"; then same=$((same+1)); continue; fi
  (cd "$W" && "$SURELOG" -parse -nocache -mt 0 -mp 0 a.sv >sl.log 2>&1 </dev/null)
  hp=-; hq=-; lp=-; lq=-
  if [ -f "$W/slpp_all/surelog.uhdm" ]; then
    hp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>&1 | grep -c '^LHS:')
    hq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>&1 | grep -c '^LHS:')
    lp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>&1 | wc -l)
    lq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>&1 | wc -l)
  fi
  printf "%-58s %-10s heads %s->%s  cmplines %s -> %s\n" "$key" MOVED "$hp" "$hq" "$lp" "$lq"
  moved=$((moved+1))
done 3<&0
echo "-- arms PROCESSED=$seen IDENTICAL=$same MOVED=$moved REJECT-BOTH=$rej ONE-SIDE=$one"
[ "$seen" -gt 0 ] || { echo "FATAL: the gate processed NOTHING"; exit 7; }
