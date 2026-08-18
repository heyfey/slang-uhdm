#!/usr/bin/env bash
# r10earl66 — build ONE arm with Surelog (golden) and with a named binary in
# BOTH views (default = -parse; elab = -elabuhdm), then print the tscen66
# census for each.  MEASUREMENT ONLY.  usage: runarm66.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${TSCEN66:?set TSCEN66}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
mkdir -p "$D"; cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null )
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
: "${SLANG_UHDM:?}"
( cd "$D" && "$SLANG_UHDM" "$B" -o o.uhdm >o.log 2>&1 </dev/null )
( cd "$D" && "$SLANG_UHDM" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null )
for t in g o oe; do
  [ -f "$D/$t.uhdm" ] && R66_INST=1 "$CEN" "$D/$t.uhdm" | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g' | sort > "$D/$t.ex"
done
wc -l "$D"/*.ex 2>/dev/null
