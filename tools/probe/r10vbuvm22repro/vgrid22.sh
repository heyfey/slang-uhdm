#!/usr/bin/env bash
# r10vbuvm22repro/vgrid22.sh — build ONE grid file with Surelog (both views) and
# with BOTH binaries (both views), census all six databases, and score with the
# VIEW-GENERAL comparator.  MEASUREMENT ONLY; uhdm-cmp is the judge.
#   vgrid22.sh <grid.sv> <pristine bin> <patched bin> <workdir> [<census bin>]
set -u
SRC=$1; PRIS=$2; PAT=$3; W=$4; CEN=${5:-/tmp/vbuvm22_cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
rm -rf "$W"; mkdir -p "$W" || exit 1
cp "$SRC" "$W/" || exit 1
B=$(basename "$SRC")
cd "$W" || exit 1
"$SURELOG" -parse -noprecompiledcache "$B" -mt 0 -mp 0 -o gd > gd.log 2>&1; echo "rc_gd=$?"
"$SURELOG" -parse -elabuhdm -noprecompiledcache "$B" -mt 0 -mp 0 -o ge > ge.log 2>&1; echo "rc_ge=$?"
"$PRIS" "$B" --single-unit            -o pd.uhdm > pd.log 2>&1; echo "rc_pd=$?"
"$PRIS" "$B" --single-unit --elabuhdm -o pe.uhdm > pe.log 2>&1; echo "rc_pe=$?"
"$PAT"  "$B" --single-unit            -o qd.uhdm > qd.log 2>&1; echo "rc_qd=$?"
"$PAT"  "$B" --single-unit --elabuhdm -o qe.uhdm > qe.log 2>&1; echo "rc_qe=$?"
for p in "gd/slpp_all/surelog.uhdm GD" "ge/slpp_all/surelog.uhdm GE" \
         "pd.uhdm PD" "pe.uhdm PE" "qd.uhdm QD" "qe.uhdm QE"; do
    set -- $p; "$CEN" "$1" "$2"
done > cen.tsv 2> cen.err
cat cen.err
