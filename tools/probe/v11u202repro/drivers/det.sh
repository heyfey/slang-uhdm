#!/bin/bash
# v11u202 (from r11u202 drivers/det.sh): the determinism control.  Each binary runs each row-mode THREE times CONCURRENTLY with the reference
# sweep's own command line and cwd (drivers/rowrun.sh's reconstruction), output to scratch; prints the distinct
# md5s per row-mode and binary.  Fail-closed on the fence (rowrun.sh refuses the four names).
# usage: det.sh <out root> <binary>...      (binaries are file names under $VB)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
O=$1; shift
ROWS="${DETROWS:-surelog:default:Earlgrey_0_1 surelog:testflags:Earlgrey_0_1 surelog:default:MiniAmiq surelog:testflags:MiniAmiq surelog:default:SeqDriver surelog:testflags:SeqDriver surelog:default:SimpleUVM surelog:testflags:SimpleUVM surelog:default:Scoreboard surelog:default:BuildUVMPkg surelog:testflags:BuildUVMPkg}"
for b in "$@"; do
  for r in $ROWS; do
    IFS=: read c m t <<< "$r"
    for k in 1 2 3; do SKIPSTRICT=1 SLANG_UHDM=$VB/$b MAX=0 bash $HERE/rowrun.sh $c $m $t $O/$b/$t.$m.$k > /dev/null 2>&1 & done
    wait
    echo "$b $t/$m $(for k in 1 2 3; do md5sum < $O/$b/$t.$m.$k/slang.uhdm | cut -c1-12; done | sort -u | tr '\n' ' ')"
  done
done
