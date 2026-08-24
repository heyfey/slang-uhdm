#!/usr/bin/env bash
# r10earl78 — compile ONE probe directory as a unit with Surelog and with a
# named binary in BOTH views, then print the cacen78 census for each.  Used to
# re-measure any EARLIER-PASS directory the per-directory boundary flags as a
# mover AGAINST GOLDEN.  rc recorded.  MEASUREMENT ONLY.
#   usage: SLANG_UHDM=<bin> CACEN78=<bin> dirarm78.sh <dir> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CACEN78:?}; D0=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2")
cp "$D0"/*.sv "$D/" 2>/dev/null
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm *.sv >sl.log 2>&1 </dev/null ); echo "rc_surelog=$?" > "$D/RC"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
: "${SLANG_UHDM:?}"
( cd "$D" && "$SLANG_UHDM" *.sv -o o.uhdm >o.log 2>&1 </dev/null ); echo "rc_slang_def=$?" >> "$D/RC"
( cd "$D" && "$SLANG_UHDM" --elabuhdm *.sv -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "rc_slang_elab=$?" >> "$D/RC"
for t in g o oe; do [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" | sort > "$D/$t.ca"; done
