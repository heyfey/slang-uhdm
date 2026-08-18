#!/usr/bin/env bash
# r10v66 verifier — one arm: Surelog golden + BOTH frozen binaries in BOTH
# views, censuses normalised, rc recorded.  MEASUREMENT ONLY.
# usage: vrun66.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${TSCEN66:-/tmp/v66_tscen66}
PAT=${PATCHED_BIN:-/tmp/v66_patched.bin}
PRIS=${PRISTINE_BIN:-/tmp/v66_pristine.bin}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null; echo "rc=$?" > sl.rc )
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS" "$B" -o o.uhdm  >o.log  2>&1 </dev/null; echo "rc=$?" > o.rc )
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null; echo "rc=$?" > oe.rc )
( cd "$D" && "$PAT"  "$B" -o p.uhdm  >p.log  2>&1 </dev/null; echo "rc=$?" > p.rc )
( cd "$D" && "$PAT"  "$B" --elabuhdm -o pe.uhdm >pe.log 2>&1 </dev/null; echo "rc=$?" > pe.rc )
for t in g o oe p pe; do
  [ -f "$D/$t.uhdm" ] && R66_INST=1 "$CEN" "$D/$t.uhdm" \
    | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g' \
    | sort > "$D/$t.ex"
done
echo "RC $(cat $D/sl.rc) sl | $(cat $D/o.rc) o | $(cat $D/oe.rc) oe | $(cat $D/p.rc) p | $(cat $D/pe.rc) pe"
wc -l "$D"/*.ex 2>/dev/null | tail -8
