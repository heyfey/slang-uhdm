#!/usr/bin/env bash
# r11u8 — NULL SWEEP: re-run ONE binary on named rows and byte-compare against
# the sweep that produced them.  A row whose bytes move here is nondeterministic
# on a FIXED binary, so its movement across two binaries proves nothing.
# usage: nullsweep8.sh <binary> <sweep workdir> <mode> <out dir> <test>...
BIN=${1:?binary}; WD=${2:?workdir}; MODE=${3:?mode}; OUT=${4:?outdir}
shift 4
mkdir -p "$OUT"
for t in "$@"; do
  d=$(ls -d "$WD/$MODE/$t"-* 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$t MISSING"; continue; }
  cmd=$(sed -n 's/^slang: *//p' "$d/cmds.txt" | head -1)
  [ -z "$cmd" ] && { echo "$t NO-SLANG-CMD"; continue; }
  o="$OUT/$t.$MODE.uhdm"
  # re-point -o at our own output, keep every other argument verbatim
  newcmd=$(echo "$cmd" | sed -E "s#^[^ ]+#$BIN#; s#-o [^ ]+#-o $o#")
  # the harness runs slang with cwd = the TEST DIRECTORY (verify_golden.py
  # `cwd=dirpath`) and `+incdir+.` depends on it, so reproduce that exactly.
  wd=$(ls -d "$TESTROOT"/*/"$t" "$TESTROOT/$t" 2>/dev/null | head -1)
  [ -z "$wd" ] && { echo "$t NO-TESTDIR"; continue; }
  ( cd "$wd" && eval "$newcmd" ) > "$OUT/$t.$MODE.log" 2>&1
  rc=$?
  if [ -f "$o" ] && [ -f "$d/slang.uhdm" ]; then
    cmp -s "$o" "$d/slang.uhdm" && echo "$t/$MODE rc=$rc SAME" || echo "$t/$MODE rc=$rc MOVED-ON-FIXED-BINARY"
  else
    echo "$t/$MODE rc=$rc NO-OUTPUT"
  fi
done
exit 0
