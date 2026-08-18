#!/usr/bin/env bash
# vbuvm20 verifier grid: golden / pristine / patched, BOTH VIEWS (default and
# -elabuhdm on our side), one census row per subroutine typespec site.
set -u
ARM=$1; PRIS=$2; PAT=$3; W=${4:-/tmp/vbuvm20_grid}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN:-/tmp/vbuvm20_cen}
rm -rf "$W"; mkdir -p "$W/g" "$W/ge" "$W/p" "$W/q" "$W/pe" "$W/qe"
for d in g ge p q pe qe; do cp "$ARM" "$W/$d/a.sv"; done
( cd "$W/g"  && "$SURELOG" a.sv -parse -d coveruhdm -nocache -createcache -noprecompiledcache -nowritecache -mt 0 -mp 0 -o s >sl.log 2>&1 ) </dev/null
( cd "$W/ge" && "$SURELOG" a.sv -parse -elabuhdm -d coveruhdm -nocache -createcache -noprecompiledcache -nowritecache -mt 0 -mp 0 -o s >sl.log 2>&1 ) </dev/null
( cd "$W/p"  && "$PRIS" a.sv -o p.uhdm >p.log 2>&1; echo "rc=$?" >> p.log ) </dev/null
( cd "$W/q"  && "$PAT"  a.sv -o q.uhdm >q.log 2>&1; echo "rc=$?" >> q.log ) </dev/null
( cd "$W/pe" && "$PRIS" a.sv --elabuhdm -o p.uhdm >p.log 2>&1; echo "rc=$?" >> p.log ) </dev/null
( cd "$W/qe" && "$PAT"  a.sv --elabuhdm -o q.uhdm >q.log 2>&1; echo "rc=$?" >> q.log ) </dev/null
$CEN "$W/g/s/slpp_all/surelog.uhdm"  G > "$W/g.txt"  2>&1
$CEN "$W/ge/s/slpp_all/surelog.uhdm" G > "$W/ge.txt" 2>&1
$CEN "$W/p/p.uhdm"  O > "$W/o.txt"  2>&1
$CEN "$W/q/q.uhdm"  P > "$W/p.txt"  2>&1
$CEN "$W/pe/p.uhdm" O > "$W/oe.txt" 2>&1
$CEN "$W/qe/q.uhdm" P > "$W/pe.txt" 2>&1
