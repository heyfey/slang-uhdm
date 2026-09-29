#!/bin/bash
# r11u215: each law's switch alone restores the pristine bytes on every grid case (both views) where that law, and no
# other law of the pass, fires (R11U215_TRACE; `diag*` lines are diagnostics, not firings); prints
# <case> <view> <law> <switch> RESTORED|NOT_RESTORED (MIXED when two laws fire).  Also R11U215_OFF on every case.
# usage: switchcheck.sh <law binary name in $B> <case dir>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LB=$1; shift
declare -A SW=([pkgTdAliasLastWriter215]=R11U215_TDALIAS_OFF [pkgImportEnumCloneLastWriter215]=R11U215_ENUMCLONE_OFF
 [impPatCopyFirstListingUnparented215]=R11U215_IMPPATFIRST_OFF [caseItemWildConcatOnly215]=R11U215_CASEWILDCAT_OFF
 [incDecOperandKeepsLvalueForm215]=R11U215_INCDECROUTE_OFF [opIdxRecvElemFollowsPath215]=R11U215_OPIDXRECV_OFF
 [opIdxRecvPlainElab215]=R11U215_OPIDXRECVELAB_OFF)
# the refinement § impPatMemberReadKeepsParent215v (R11V215_MEMBERREAD_OFF) writes no firing line of its own (its
# trace is diagImpPatMemberRead215): refcheck.sh measures its switch.
T=/tmp/r11u215_swchk; mkdir -p $T
for c in "$@"; do for f in $FENCED; do grep -qw "$f" <<< "$c" && continue 2; done
  for E in "" --elabuhdm; do k=$(echo "$c$E" | md5sum | cut -c1-10); o=$T/$k; rm -rf $o; mkdir -p $o/tr
    ( cd $c && R11U215_TRACE=$o/tr $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/law.uhdm >/dev/null 2>&1; $B/pris.bin dut.sv --single-unit --nobuiltin $E -o $o/pris.uhdm >/dev/null 2>&1
      R11U215_OFF=1 $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/alloff.uhdm >/dev/null 2>&1 )
    cmp -s $o/alloff.uhdm $o/pris.uhdm && ao=ALLOFF=pristine || ao=ALLOFF=DIFF
    laws=$(cat $o/tr/*.T215 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | grep -v '^diag' | sort -u)
    n=$(echo "$laws" | grep -c .)
    cmp -s $o/law.uhdm $o/pris.uhdm && mv=same || mv=moved
    if [ "$n" = 0 ]; then echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} none - $mv $ao"; continue; fi
    if [ "$n" != 1 ]; then
      for l in $laws; do ( cd $c && env ${SW[$l]}=1 $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/off.uhdm >/dev/null 2>&1 ); cmp -s $o/off.uhdm $o/law.uhdm && r=NOEFFECT || r=DROPS; echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} MIXED:$l ${SW[$l]} $r $ao"; done; continue; fi
    ( cd $c && env ${SW[$laws]}=1 $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/off.uhdm >/dev/null 2>&1 )
    cmp -s $o/off.uhdm $o/pris.uhdm && r=RESTORED || r=NOT_RESTORED
    echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} $laws ${SW[$laws]} $r $mv $ao"
  done; done
