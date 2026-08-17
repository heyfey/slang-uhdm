#!/usr/bin/env bash
# r10uvm85 — ct85cen over a WHOLE sweep workdir.  MEASUREMENT-ONLY.
#
#   usage: pred85.sh <workdir> [<ct85cen>]
#
# Prints one line per database (mode/test  OBJS.. PRED n) and then the list of
# databases with PRED>0 — the PREDICTED BYTE MOVERS, by name, taken from
# PRISTINE databases BEFORE the patched sweep is run.  A database that fails to
# restore is printed as RESTORE_FAIL and counted; a workdir with no databases
# exits 4 (a vacuous run must never read as "nothing moves").
set -u
WD=${1:?workdir}
CEN=${2:-/tmp/r10uvm85_ct85cen}
[ -x "$CEN" ] || { echo "FATAL: no ct85cen at $CEN"; exit 3; }
n=0; nz=0; fail=0
: > /tmp/r10uvm85_pred_rows.txt
while IFS= read -r db; do
  n=$((n+1))
  key=${db#$WD/}; key=${key%/slang.uhdm}
  line=$("$CEN" "$db" 2>/dev/null) || { echo "RESTORE_FAIL $key"; fail=$((fail+1)); continue; }
  p=$(echo "$line" | sed -n 's/.* PRED \([0-9]*\) .*/\1/p')
  echo "$key $line" >> /tmp/r10uvm85_pred_rows.txt
  [ "${p:-0}" -gt 0 ] && nz=$((nz+1))
done < <(find "$WD" -name slang.uhdm | sort)
[ "$n" -gt 0 ] || { echo "NO_DATABASES"; exit 4; }
echo "== databases=$n  PRED>0=$nz  RESTORE_FAIL=$fail"
echo "== PREDICTED MOVERS (PRED>0), by name:"
awk '{for(i=1;i<=NF;i++) if($i=="PRED"){p=$(i+1)}} p>0 {print "  " $1 "  " $0}' \
    /tmp/r10uvm85_pred_rows.txt | sed 's/\/tmp[^ ]*slang.uhdm//'
