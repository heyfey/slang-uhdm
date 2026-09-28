#!/bin/bash
# r11u209: every switch alone. For each case-view of cases/ (and the r11u205dec GS/IP grids), runs the law binary
# plain with R11U209_TRACE, then once per switch with only that switch set; a case-view whose bytes move under a
# switch must carry a firing of that switch's law (UNTRACED otherwise). usage: switches.sh <law bin> <outdir>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LB=$1; O=$2; rm -rf $O; mkdir -p $O
SW="R11U205_GENIDXSEL_OFF:genConnTrailSelChain205 R11U205_IPSNAME_OFF:defGenTargetIpsDefName205 R11U205_PORTDECLTS_OFF:ifacePortDeclTsAtPortDecl205 R11U209_TWINELEM_OFF:twinElemOnlyNoRange209 R11U209_ARRTDCLONE_OFF:pkgArrTdElemClone209 R11U209_OPLEAFCHAIN_OFF:portConnOpLeafChain209 R11U209_MPORPHAN_OFF:modportOpOrphanReparent209 R11U209_TFINITTYPE_OFF:tfItemInitLocalAtType209 R11U209_TFSPECNAME_OFF:tfItemLocalSpecAtName209 R11U209_CLSENUMMEM_OFF:classTdPkgEnumMemberShares209"
run() { c=$1; el=$2; k=$(echo $c | sed 's#.*/cases/##; s#/#_#g')$([ $el = 1 ] && echo _el); ox=""; [ $el = 1 ] && ox=--elabuhdm
  src=dut.sv; [ -f $c/dut.sv ] || src=dut.v
  mkdir -p $O/$k/tr; (cd $c && R11U209_TRACE=$O/$k/tr $LB $src --single-unit --nobuiltin $ox -o $O/$k/plain.uhdm > /dev/null 2>&1)
  pm=$(md5sum < $O/$k/plain.uhdm 2>/dev/null | cut -c1-12); laws=$(cat $O/$k/tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u | tr '\n' ' ')
  line="$k"
  for sl in $SW; do s=${sl%%:*}; l=${sl##*:}; rm -f $O/$k/s.uhdm
    (cd $c && env $s=1 $LB $src --single-unit --nobuiltin $ox -o $O/$k/s.uhdm > /dev/null 2>&1)
    sm=$(md5sum < $O/$k/s.uhdm 2>/dev/null | cut -c1-12)
    if [ "$sm" != "$pm" ]; then echo "$laws" | grep -qw "$l" && line="$line $l:moved" || line="$line $l:UNTRACED"; fi
  done; echo "$line"; }
export -f run; export O LB SW
{ find $HERE/../cases -name dut.sv -printf '%h\n'; find /home/heyfey/git-repos/slang-uhdm/tools/probe/r11u205dec/cases/GS /home/heyfey/git-repos/slang-uhdm/tools/probe/r11u205dec/cases/IP -name dut.sv -printf '%h\n'; } | sort | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P2 -L1 bash -c 'run $0 $1' | sort > $O/switches.txt
echo "case-views $(wc -l < $O/switches.txt), UNTRACED $(grep -c UNTRACED $O/switches.txt)"
