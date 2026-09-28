#!/bin/bash
# v11u209: switches.sh <binary> <tag-prefix> -- every law switch alone (and the pass switches) over cases/: the case-views
# whose bytes move against the all-on run must carry a firing of THAT switch's law (R11U209_TRACE over the all-on run).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
b=$1; p=$2; export GW=${GW:-/tmp/v11u209_gS}; T=/tmp/v11u209_trgrid; rm -rf $T; mkdir -p $T
bash $HERE/grid.sh ${p}on $b R11U209_TRACE=$T > /tmp/v11u209_sw_${p}on.txt 2>&1
for f in $T/*; do o=$(head -1 $f | sed 's/^OUT //'); sed 1d $f | awk -v o="$o" '{print o, $1}'; done | sed -E "s#^$GW/##; s#/${p}on\.uhdm##" | sort -u > /tmp/v11u209_sw_fire.txt
while read sw law; do
  bash $HERE/grid.sh ${p}sw $b $sw=1 > /tmp/v11u209_sw_${p}_$sw.txt 2>&1
  moved=$(join <(awk '{print $1,$7}' /tmp/v11u209_sw_${p}on.txt | LC_ALL=C sort) <(awk '{print $1,$7}' /tmp/v11u209_sw_${p}_$sw.txt | LC_ALL=C sort) | awk '$2!=$3{print $1}')
  n=0; u=0; for c in $moved; do n=$((n+1)); grep -q "^$c $law$" /tmp/v11u209_sw_fire.txt || { u=$((u+1)); echo "  UNTRACED $sw $c"; }; done
  echo "$sw ($law): moved=$n untraced=$u"
done <<'LST'
R11U205_GENIDXSEL_OFF genConnTrailSelChain205
R11U205_IPSNAME_OFF defGenTargetIpsDefName205
R11U205_PORTDECLTS_OFF ifacePortDeclTsAtPortDecl205
R11U209_TWINELEM_OFF twinElemOnlyNoRange209
R11U209_ARRTDCLONE_OFF pkgArrTdElemClone209
R11U209_OPLEAFCHAIN_OFF portConnOpLeafChain209
R11U209_MPORPHAN_OFF modportOpOrphanReparent209
R11U209_TFINITTYPE_OFF tfItemInitLocalAtType209
R11U209_TFSPECNAME_OFF tfItemLocalSpecAtName209
R11U209_CLSENUMMEM_OFF classTdPkgEnumMemberShares209
R11V209_MPCONCAT_OFF mpOrphanSkipConcat209v
R11V209_MPLATER_OFF mpOrphanLaterWriter209v
R11V209_PDNAMED_OFF pdTsNotTypedefListing209v
LST
