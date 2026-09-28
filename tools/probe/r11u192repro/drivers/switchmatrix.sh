#!/bin/bash
# switchmatrix.sh <pristine bin> <law bin> <out> [roots...]: per switch S and per case (default view), the law binary
# with S set must write the PRISTINE bytes where every firing law is governed by S, and the LAW bytes where no law
# governed by S fires (mixed cases are reported MIXED).  Fence-refusing.
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(sed -n 's/^FENCED="\(.*\)"$/\1/p' $REPO/tools/probe/r11u107repro/canaudit.sh)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "switchmatrix: fence unreadable" >&2; exit 3; }
FRE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
P=$1; L=$2; O=$3; shift 3; roots=("$@"); [ ${#roots[@]} -eq 0 ] && roots=("$HERE/../cases")
declare -A LAWS=(
 [R11U192_PSOWNER_OFF]="psBoundPaOwnerName192"
 [R11U192_GFREPL_OFF]="genForReplCountOwner192"
 [R11U192_PROCPS_OFF]="procPsBoundOwner192"
 [R11U192_TFPS_OFF]="tfPsBoundOwner192"
 [R11U192_NDAPS_OFF]="ndaPsBoundOwner192"
 [R11U192_PSVERB_OFF]="caPsSelFullVerbatim192"
 [R11U192_QBSPAN_OFF]="pkgQualBoundSpanQualifier192"
 [R11U192_PATTD_OFF]="pkgPatReadTsBindsTopTypedef192"
 [R11U192_OFF]="psBoundPaOwnerName192 genForReplCountOwner192 procPsBoundOwner192 tfPsBoundOwner192 ndaPsBoundOwner192 caPsSelFullVerbatim192 pkgQualBoundSpanQualifier192 pkgPatReadTsBindsTopTypedef192"
)
T=/tmp/r11u192_sw; rm -rf $T; mkdir -p $T; : > $O
for c in $(find "${roots[@]}" -name dut.sv -printf '%h\n' | sort); do
  echo "$c" | grep -qP "$FRE" && { echo "FENCE $c" >> $O; continue; }
  rm -f $T/p.uhdm $T/l.uhdm
  (cd $c && $P dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1)
  rm -rf $T/tr; mkdir -p $T/tr
  (cd $c && R11U192_TRACE=$T/tr $L dut.sv --single-unit --nobuiltin -o $T/l.uhdm >/dev/null 2>&1)
  fired=$(cat $T/tr/* 2>/dev/null | grep -v '^OUT ' | sort -u | tr '\n' ' ')
  for S in "${!LAWS[@]}"; do
    gov=0; oth=0
    for f in $fired; do if echo " ${LAWS[$S]} " | grep -q " $f "; then gov=1; else oth=1; fi; done
    rm -f $T/s.uhdm; (cd $c && env $S=1 $L dut.sv --single-unit --nobuiltin -o $T/s.uhdm >/dev/null 2>&1)
    sp=$(cmp -s $T/s.uhdm $T/p.uhdm && echo P || echo -); sl=$(cmp -s $T/s.uhdm $T/l.uhdm && echo L || echo -)
    if [ $gov = 1 ] && [ $oth = 0 ]; then exp=P; elif [ $gov = 0 ]; then exp=L; else exp=MIXED; fi
    got=$sp$sl
    ok=BAD; case $exp in P) [[ $got == P* ]] && ok=ok;; L) [[ $got == *L ]] && ok=ok;; MIXED) ok=mixed;; esac
    echo "$ok $S expect=$exp got=$got fired=[$fired] $c" >> $O
  done
  rm -f $T/p.uhdm $T/l.uhdm
done
echo "ok=$(grep -c '^ok' $O) bad=$(grep -c '^BAD' $O) mixed=$(grep -c '^mixed' $O)"
