#!/bin/bash
# r11v70 — ONE ARM, THREE BINARIES + GOLDEN.  Runs a .sv through Surelog
# (the canonical v1.87 golden producer) and through each slang-uhdm binary
# named in BINS, dumps every side, normalises ids and workdir paths, and
# reports the ORDER-BLIND distance of each of ours to golden plus the
# per-module NET LIST of each side.  The net list is the point: the mint this
# family performs lands in `instance::Nets()`, which `instance::Compare`
# reads as a VECTOR (UHDM generated/src/instance.cpp:336), and each net's
# `VpiNetType` is read too (generated/src/nets.cpp:277).
#   usage: BINS="pris=/path/a law=/path/b" arm3.sh <file.sv> <outdir>
set -u
F=$(readlink -f "${1:?file}"); OUT=${2:?outdir}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
N=$(basename "$F" .sv)
rm -rf "$OUT"; mkdir -p "$OUT/g"
norm(){ sed -e "s#$OUT[A-Za-z0-9_./-]*##g" -e 's/, id:[0-9]*//g' -e 's/id:[0-9]*//g' | sed '1s#.*#HDR#'; }
nets(){ awk '/uhdmallModules/,/uhdmtopModules/' "$1" | grep -A1 '^  |vpiNet:' |
        grep _logic_net | sed 's/.*(\([^)]*\)).*/\1/' | tr '\n' ',' ; }
( cd "$OUT/g" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); grc=$?
G=$(ls "$OUT"/g/slpp_all/*.uhdm 2>/dev/null | head -1)
echo "ARM $N surelog rc=$grc errors=$(grep -c '\[ERROR\]' "$OUT/g/sl.log"; true)"
[ -n "$G" ] && "$DUMP" "$G" 2>&1 | norm > "$OUT/$N.g.norm"
echo "  GOLDEN nets: $(nets "$OUT/$N.g.norm")"
for kv in $BINS; do
  k=${kv%%=*}; b=${kv#*=}
  mkdir -p "$OUT/$k"
  ( cd "$OUT/$k" && "$b" "$F" --single-unit -o slang.uhdm > our.log 2>&1 ); rc=$?
  [ -f "$OUT/$k/slang.uhdm" ] && "$DUMP" "$OUT/$k/slang.uhdm" 2>&1 | norm > "$OUT/$N.$k.norm"
  d=$(diff <(sort "$OUT/$N.g.norm") <(sort "$OUT/$N.$k.norm") 2>/dev/null | grep -c '^[<>]'; true)
  echo "  $k rc=$rc gdist=$d nets: $(nets "$OUT/$N.$k.norm")"
done
