#!/usr/bin/env bash
# fpcells.sh <arm outdir from arm.sh> <arm dir> <binary> [extra flag]: builds ours
# with the downstream translation (-DSYNTHESIS dut.sv --single-unit --nobuiltin
# --filterprotected) and scores the LOCATION multiset (locdump: type, name,
# file, span, parent chain) against the downstream-lane golden gds.uhdm.
set -u; export LC_ALL=C
O=$1; A=$(cd "$2" && pwd); B=$3; X=${4:---filterprotected}
LD=${LD:-/tmp/r11u120_locdump}
rm -f "$O/ours_fp.uhdm"
(cd "$A" && $B -DSYNTHESIS dut.sv --single-unit --nobuiltin $X -o "$O/ours_fp.uhdm" >/dev/null 2>&1); rc=$?
$LD "$O/gds.uhdm" | sed "s#/[^ ]*/##g" | sort > "$O/loc_g.txt"; $LD "$O/ours_fp.uhdm" | sed "s#/[^ ]*/##g" | sort > "$O/loc_o.txt"
g=$(wc -l < "$O/loc_g.txt"); m=$(comm -12 "$O/loc_g.txt" "$O/loc_o.txt" | wc -l)
# the line cells alone: rows whose golden span line differs from ours for the same kind+name
echo "FPCELLS $(basename $O) rc=$rc golden=$g matched=$m"
