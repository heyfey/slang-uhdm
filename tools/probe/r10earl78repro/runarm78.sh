#!/usr/bin/env bash
# r10earl78 — build ONE arm with Surelog (golden) and with a named binary in
# BOTH views (default = -parse; elab = -elabuhdm), then print the cacen78
# whole-Rhs cont_assign census for each.  MEASUREMENT ONLY.
#   usage: SLANG_UHDM=<bin> CACEN78=<bin> runarm78.sh <file.sv> <outdir>
# rc of every producer is RECORDED (verify_golden.py records rc=139 as
# SLANG_REJECT wearing a stderr warning — an arm must never hide one).
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CACEN78:?set CACEN78}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "rc_surelog=$?" >> "$D/RC"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
: "${SLANG_UHDM:?}"
( cd "$D" && "$SLANG_UHDM" "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "rc_slang_def=$?" >> "$D/RC"
( cd "$D" && "$SLANG_UHDM" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "rc_slang_elab=$?" >> "$D/RC"
for t in g o oe; do
  [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" | sort > "$D/$t.ca"
done
wc -l "$D"/*.ca 2>/dev/null
