#!/usr/bin/env bash
# r10oth1 probe driver.  Runs Surelog and slang-uhdm on ONE source, dumps both,
# diffs, and cmps.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: probe.sh <workdir-containing-the-source> <source.v> [extra slang args]
#
# SLANG_UHDM must point at the build under test.  It DEFAULTS TO NOTHING here on
# purpose: scripts/verify_golden.py and tests/check_goldens.sh both default it
# to the MAIN-TREE binary, and measuring the wrong binary is indistinguishable
# from a pass.  Set it explicitly, and prove the export works with the negative
# control (SLANG_UHDM=/bin/false must make all 23 goldens FAIL).
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
D=$1; SRC=$2; shift 2
cd "$D" || exit 9
"$SURELOG" -parse -nobuiltin -nocache "$SRC" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL"; tail -5 surelog.log; exit 5; }
"$SLANG_UHDM" "$SRC" --nobuiltin -o slang.uhdm "$@" >slang.log 2>&1 ||
    { echo "SLANG rc=$?"; tail -20 slang.log; }
[ -f slang.uhdm ] || { echo "NO_OUTPUT (slang produced no database -- uhdm-cmp\n  EXITS 0 on a missing input, so without this guard the next line would\n  print PASS_CMP on nothing.  Measured by the pass-47-era verifier.)";\n  tail -5 slang.log 2>/dev/null; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump   # LHS golden
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump              # RHS ours
diff -u g.dump o.dump > d.diff && echo DUMP_MATCH ||
    echo "DUMP_DIFF $(grep -c '^[-+]' d.diff)"
"$CMP" slpp_all/surelog.uhdm slang.uhdm > cmp.log 2>&1 && echo PASS_CMP ||
    echo "CMP_FAIL (see cmp.log; LHS=golden, RHS=ours)"
