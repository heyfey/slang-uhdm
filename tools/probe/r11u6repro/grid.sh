#!/bin/bash
# r11u6 GOLDEN GRID.  Per arm: surelog rc, both binaries' rc, cmp-line count
# and head, plus the per-listing FOLD/EDGE census from tsedge (identity read
# from the OBJECT POINTER, never from dump order).
#   usage: grid.sh <pristine-bin> <law-bin> [arm...]
# `--nobuiltin` is REQUIRED on the slang side (the harness passes it); without
# it the builtin package makes the whole design a vector-size mismatch and the
# head is meaningless.
set -u
PRIS=${1:?pristine binary}; LAW=${2:?law binary}; shift 2
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDMCMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
TSEDGE=${TSEDGE:-/tmp/r11u6_tsedge}
ARMS=${*:-$(cd "$HERE/grid" && ls -d g* )}
for a in $ARMS; do
  d="$HERE/grid/$a"
  [ -d "$d" ] || { echo "$a NO-DIR"; continue; }
  W=${GRIDWD:-/tmp/r11u6_gridwd}/$a
  rm -rf "$W"; mkdir -p "$W"; cp "$d/dut.sv" "$W/"
  ( cd "$W" && "$SL" -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1 ); slrc=$?
  ( cd "$W" && "$PRIS" dut.sv --single-unit --nobuiltin -o pris.uhdm > pris.log 2>&1 ); prc=$?
  ( cd "$W" && "$LAW"  dut.sv --single-unit --nobuiltin -o law.uhdm  > law.log  2>&1 ); lrc=$?
  echo "=================== $a   surelog_rc=$slrc pristine_rc=$prc law_rc=$lrc"
  head -3 "$d/dut.sv" | sed 's/^/   /'
  for b in pris law; do
    [ -f "$W/$b.uhdm" ] || { echo "   $b: NO DATABASE"; continue; }
    "$CMP" "$W/slpp_all/surelog.uhdm" "$W/$b.uhdm" > "$W/$b.cmp.out" 2> "$W/$b.cmp.err"
    n=$(( $(wc -l < "$W/$b.cmp.out") + $(wc -l < "$W/$b.cmp.err") ))
    h=$(grep -c '^LHS:' "$W/$b.cmp.err"; true)
    printf '   %-5s cmplines=%-6s heads=%-3s head=%s\n' "$b" "$n" "$h" \
        "$(grep -A2 '^LHS:' "$W/$b.cmp.err" | sed -n 3p)"
  done
  if [ -x "$TSEDGE" ] && [ -f "$W/law.uhdm" ]; then
    echo "   ---- per-listing fold/edge census (golden | pristine | law)"
    "$TSEDGE" "$W/slpp_all/surelog.uhdm" "$W/pris.uhdm" "$W/law.uhdm" | sed 's/^/   /'
  fi
done
