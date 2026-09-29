#!/bin/bash
# r11u215: judge one case dir (dut.sv) the way scripts/check_probe.py does, keeping everything.
# usage: case.sh <case dir> [outdir]   env: SLANG_UHDM (the binary under test, absolute), SCMP (uhdm-strictcmp)
# writes <outdir>/{golden.uhdm,ours.uhdm,strict.txt,a.rec,b.rec,g.dump,o.dump}; golden cached per text md5
# in /tmp/r11u215_gold/<md5>/. Refuses the four fenced names (the FENCED= line of r11u107repro/canaudit.sh).
set -u
D=$(cd "$1" && pwd); O=${2:-/tmp/r11u215_run/$(echo "$D" | md5sum | cut -c1-12)}
HERE=$(cd "$(dirname "$0")" && pwd)
REPO="$(cd "$(git -C "$HERE" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"; FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "case.sh: fence unreadable" >&2; exit 3; }
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "case.sh: fenced path refused" >&2; exit 3; }; done
: "${SURELOG:=/home/heyfey/git-repos/Surelog/build/bin/surelog}" "${UHDM_DUMP:=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}"
: "${UHDM_CMP:=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}" "${SCMP:=/tmp/r11u215_bin/uhdm-strictcmp}"
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/*.dump "$O"/strict.txt
# an `args` file lists the root files of one compilation unit (r11u190's convention)
SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args"); [ ! -f "$D/args" ] && [ -f "$D/files" ] && SRC=$(cat "$D/files" | tr "\n" " ")
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/r11u215_gold/$K${ELAB:+_elab}
# ELAB=1: the -elabuhdm form on both sides (Surelog -elabuhdm, ours --elabuhdm)
SLE=; OUE=; [ -n "${ELAB:-}" ] && { SLE=-elabuhdm; OUE=--elabuhdm; }
# a `nosv` file in the case dir: Verilog-mode sources (Surelog without -sv; our side as always)
SVF=-sv; [ -f "$D/nosv" ] && SVF=
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse $SLE -nobuiltin -nocache $SVF $SRC -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
cp "$G/golden.uhdm" "$O/golden.uhdm"
( cd "$D" && "$SLANG_UHDM" $SRC --single-unit --nobuiltin $OUE -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $(tail -1 $O/slang.log)"; exit 1; }
"$UHDM_CMP" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1; src=$?
"$UHDM_DUMP" "$O/golden.uhdm" 2>/dev/null | sed "s#$G[^ ]*##g" > "$O/g.dump"; "$UHDM_DUMP" "$O/ours.uhdm" 2>/dev/null > "$O/o.dump"
echo "cmp=$crc strict=$src $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) out=$O"
