#!/bin/bash
# r11u188: § svModeAllFiles188 by hand.  svmode.sh <binary, absolute> <sweep workdir> <row>...: for each row-mode of a
# sweep (surelog corpus), re-runs the row's own translated slang command (its cmds.txt) with and without --sverilog and
# prints uhdm-strictcmp's verdict against the row's cached golden.  Refuses the fenced names.
. "$(dirname "$0")/env.sh" || exit 3
B=$1; W=$2; shift 2
for r in "$@"; do
  r188_fenced "$r" && { echo "svmode.sh: fenced row refused" >&2; exit 3; }
  for m in default testflags; do
    d=$(ls -d $W/surelog/$m/$r-* 2>/dev/null | head -1); [ -n "$d" ] || continue
    g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
    cmd=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//; s# -o [^ ]*##; s#^[^ ]*##')
    src=$SURELOG_ROOT/tests/$r
    for fl in "" "--sverilog"; do
      o=/tmp/r11u188_svmode_$$.uhdm; rm -f $o
      (cd $src && $B $cmd $fl -o $o > /dev/null 2>&1 < /dev/null)
      echo "$r $m [${fl:-no flag}] $($SCMP --max 1 $g $o 2>&1 | tail -1)"; rm -f $o
    done
  done
done
