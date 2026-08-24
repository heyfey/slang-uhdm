#!/usr/bin/env bash
# r10v78 — one arm, Surelog golden + BOTH frozen binaries in BOTH views.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=/tmp/v78_probe/cacen78
F=$(readlink -f "$1"); D=$(readlink -f "$2"); mkdir -p "$D"; B=$(basename "$F")
cp "$F" "$D/"; : > "$D/RC"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "rc_surelog=$?" >> "$D/RC"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
for tag in pris patched; do
  bin=/tmp/v78_bin/pristine; [ $tag = patched ] && bin=/tmp/v78_bin/patched
  ( cd "$D" && "$bin" "$B" -o ${tag}_d.uhdm >${tag}_d.log 2>&1 </dev/null ); echo "rc_${tag}_def=$?" >> "$D/RC"
  ( cd "$D" && "$bin" "$B" --elabuhdm -o ${tag}_e.uhdm >${tag}_e.log 2>&1 </dev/null ); echo "rc_${tag}_elab=$?" >> "$D/RC"
done
for t in g pris_d pris_e patched_d patched_e; do
  [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" | sort > "$D/$t.ca"
done
cat "$D/RC"; wc -l "$D"/*.ca 2>/dev/null
