#!/bin/bash
# r11u210: each law's switch alone restores the pristine bytes on every grid case (both views) where that law, and no
# other law of the pass, fires (R11U210_TRACE); prints <case> <view> <law> RESTORED|NOT_RESTORED.
# usage: switchcheck.sh <law binary name in $B> <case dir>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LB=$1; shift
declare -A SW=([elabIfArrIdxChainName205]=R11U205_IFARRIDX_OFF [elabIfArrIdxExprChainName210]=R11U210_IFARREXPR_OFF
 [memLeftReadsPatUnlocated210]=R11U210_MLPATLOC_OFF [pkgTopWidePatReplTsName210]=R11U210_PKGREPLTS_OFF
 [caseItemImpWildParamScopeName210]=R11U210_CASEWILD_OFF [pkgImpParamMemberColons210]=R11U210_PKGIMPCOLON_OFF
 [pkgImpParamAliasColons210]=R11U210_PKGIMPALIAS_OFF)
T=/tmp/r11u210_swchk; mkdir -p $T
for c in "$@"; do for f in $FENCED; do grep -qw "$f" <<< "$c" && continue 2; done
  for E in "" --elabuhdm; do k=$(echo "$c$E" | md5sum | cut -c1-10); o=$T/$k; rm -rf $o; mkdir -p $o/tr
    ( cd $c && R11U210_TRACE=$o/tr $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/law.uhdm >/dev/null 2>&1; $B/pris.bin dut.sv --single-unit --nobuiltin $E -o $o/pris.uhdm >/dev/null 2>&1 )
    laws=$(cat $o/tr/*.T210 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u)
    [ "$(echo "$laws" | grep -c .)" = 1 ] || { [ -n "$laws" ] && echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} MIXED $(echo $laws)"; continue; }
    ( cd $c && env ${SW[$laws]}=1 $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/off.uhdm >/dev/null 2>&1 )
    cmp -s $o/off.uhdm $o/pris.uhdm && r=RESTORED || r=NOT_RESTORED
    echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} $laws ${SW[$laws]} $r"
  done; done
