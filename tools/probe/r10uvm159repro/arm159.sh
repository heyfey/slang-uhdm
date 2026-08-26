#!/bin/bash
# r10uvm159 — GRID/BOUNDARY ARM RUNNER.  MEASUREMENT ONLY; uhdm-cmp is the judge.
# Builds golden (Surelog) and ours (slang-uhdm) for ONE arm source and prints
# the classified constant/typespec census (ct159cls) for the pair.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * the arm scratch is keyed on the arm's RELATIVE path, so two arms with the
#     same basename in different directories cannot clobber each other;
#   * SLANG_UHDM must be exported EXPLICITLY — verify_golden.py and
#     check_goldens.sh both silently default to the MAIN-TREE binary;
#   * BOTH tool exit codes are recorded (rc=139 segfaults otherwise read as a
#     polite rejection), and a missing database prints NOGOLDEN/NOOURS and is
#     COUNTED — an arm that reaches nothing must never read as perfection.
#
#   usage: SLANG_UHDM=<bin> arm159.sh <out-dir> <arm.sv> [<arm.sv> ...]
set -u
OUT=${1:?outdir}
shift
SLANG=${SLANG_UHDM:?export SLANG_UHDM}
# THE GOLDEN PRODUCER IS scripts/verify_golden.py's SURELOG and no other:
# ~/git-repos/Surelog/build/bin/surelog.  The sv-tests copy is a DIFFERENT,
# OLDER build whose databases the installed libuhdm SEGFAULTS on -- an arm run
# with it produces a 19 MB file and zero cells.
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
UVM=${UVM:-$HOME/git-repos/Surelog/third_party/UVM/uvm-1.2/src}
CLS=${CLS:-/tmp/wt_r10uvm159/tools/probe/r10uvm159repro/ct159cls}
mkdir -p "$OUT" || exit 1
for f in "$@"; do
  [ -f "$f" ] || { echo "ARM $f MISSING-SOURCE"; continue; }
  b=$(basename "$f" .sv)
  d=$OUT/$b
  rm -rf "$d"; mkdir -p "$d"
  cp "$f" "$d/dut.sv"
  # -noprecompiledcache is MANDATORY whenever uvm_pkg.sv is on the command
  # line (scripts/verify_golden.py's `precompiled_guard`): without it Surelog
  # serves uvm_pkg from its BUNDLED precompiled cache and writes a database
  # that the installed libuhdm -- and the official uhdm-cmp -- SEGFAULT on.
  # A driver missing this flag reads as "no cells" instead of "no database".
  # -mt 0 -mp 0 is MANDATORY too (scripts/verify_golden.py passes both):
  # Surelog's default multi-threaded compile writes a database the installed
  # libuhdm cannot Restore -- `Serializer::Restore` and the official uhdm-cmp
  # both SEGFAULT on it, which reads as "the arm has no cells".
  ( cd "$d" && timeout 900 "$SURELOG" -parse -noprecompiledcache -nocache \
      -mt 0 -mp 0 +incdir+.+"$UVM"/ "$UVM"/uvm_pkg.sv dut.sv \
      -o "$d/sl" > sl.log 2>&1 ); grc=$?
  ( cd "$d" && timeout 900 "$SLANG" +incdir+.+"$UVM"/ "$UVM"/uvm_pkg.sv dut.sv \
      --single-unit -o "$d/o.uhdm" > o.log 2>&1 ); orc=$?
  G=$d/sl/slpp_all/surelog.uhdm
  [ -f "$G" ] || { echo "ARM $b NOGOLDEN grc=$grc orc=$orc"; continue; }
  [ -f "$d/o.uhdm" ] || { echo "ARM $b NOOURS grc=$grc orc=$orc"; continue; }
  echo "ARM $b grc=$grc orc=$orc"
  "$CLS" "$G" "$d/o.uhdm" --tag="$b" --list
done
