#!/usr/bin/env bash
# r10v154 — one-arm runner: golden (Surelog) + up to three of our binaries,
# extracting the enum_const cell set from each.  Binaries come from $V154_BIN
# (default /tmp/v154_bin) as pris/pat/fix.  MEASUREMENT ONLY; the official
# uhdm-cmp is the judge.  LHS is ALWAYS golden.
#   usage: [V154_BIN=<dir with pris/pat/fix>] vrun154.sh <abs arm.sv> <scratch root>
#
# Ops traps encoded here (RESUME.md §9): Surelog synthesises builtin.sv in the
# CWD, so every arm runs in its OWN scratch dir keyed on the arm name; every rc
# is recorded (verify_golden.py files an rc=139 SEGFAULT as SLANG_REJECT); the
# dump's first line is the database path and is cut.
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRC=$1; ROOT=$2
B=$(basename "$SRC"); B=${B%.sv}
D=$ROOT/$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/$B.sv"
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$B.sv" >surelog.log 2>&1
src_rc=$?
if [ -f slpp_all/surelog.uhdm ]; then
  "$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
  python3 "$HERE/vcells154.py" g.dump | sort > g.cells
else
  echo "SURELOG_FAIL" > g.cells
fi
for T in pris pat fix; do
  ${V154_BIN:-/tmp/v154_bin}/$T "$B.sv" -o $T.uhdm > $T.log 2>&1
  rc=$?
  echo "$rc" > $T.rc
  if [ -f $T.uhdm ]; then
    "$DUMP" $T.uhdm 2>/dev/null | sed 1d > $T.dump
    python3 "$HERE/vcells154.py" $T.dump | sort > $T.cells
  else
    echo "SLANG_REJECT rc=$rc" > $T.cells
  fi
done
echo "ARM $B pris_rc=$(cat pris.rc) pat_rc=$(cat pat.rc) golden=$( [ -f slpp_all/surelog.uhdm ] && echo OK || echo FAIL )"
