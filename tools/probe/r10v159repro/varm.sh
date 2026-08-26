#!/bin/bash
# v159 VERIFIER arm runner — standalone (NO UVM) arms.
# usage: varm.sh <outdir> <arm.sv> ...
# env: SLANG_UHDM (required, explicit), SURELOG (verify_golden.py's binary)
set -u
OUT=${1:?outdir}; shift
SLANG=${SLANG_UHDM:?export SLANG_UHDM}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CLS=${CLS:?export CLS=<path to r10uvm159repro/ct159cls>}
mkdir -p "$OUT" || exit 1
for f in "$@"; do
  [ -f "$f" ] || { echo "ARM $f MISSING-SOURCE"; continue; }
  b=$(basename "$f" .sv)
  d=$OUT/$b
  mkdir -p "$d"; cp "$f" "$d/dut.sv"
  if [ ! -f "$d/sl/slpp_all/surelog.uhdm" ]; then
    ( cd "$d" && timeout 900 "$SURELOG" -parse -noprecompiledcache -nocache \
        -mt 0 -mp 0 +incdir+. dut.sv -o "$d/sl" > sl.log 2>&1 ); echo "grc=$? " > "$d/grc"
  fi
  ( cd "$d" && timeout 900 "$SLANG" dut.sv --single-unit -o "$d/o.uhdm" > o.log 2>&1 ); orc=$?
  G=$d/sl/slpp_all/surelog.uhdm
  [ -f "$G" ] || { echo "ARM $b NOGOLDEN $(cat $d/grc 2>/dev/null) orc=$orc"; continue; }
  [ -f "$d/o.uhdm" ] || { echo "ARM $b NOOURS $(cat $d/grc 2>/dev/null) orc=$orc"; continue; }
  echo "ARM $b $(cat $d/grc 2>/dev/null) orc=$orc"
  "$CLS" "$G" "$d/o.uhdm" --tag="$b" --list
done
