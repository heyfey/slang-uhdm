#!/bin/bash
# reach205.sh: the switch reach of landing 205 (§ landingSwitchReach220).  Every case dir of tools/probe/r11u205dec
# (the four r11u205 laws' grids) and this pass's IA grid, both views, on the law binary ($B/$LAWBIN) under: no
# switch, R11U205_OFF, R11U220_LANDING205A_OFF, R11U205_IFARRIDX_OFF; prints per case-view the four md5s and which
# states equal which.  Uses case.sh (fence fail-closed).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAWBIN=${LAWBIN:-law.bin}
one() { c=$1; el=$2
  m0=$(EL=$el bash $HERE/case.sh $c R0 $B/$LAWBIN 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m1=$(EL=$el bash $HERE/case.sh $c R1 $B/$LAWBIN R11U205_OFF=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m2=$(EL=$el bash $HERE/case.sh $c R2 $B/$LAWBIN R11U220_LANDING205A_OFF=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m3=$(EL=$el bash $HERE/case.sh $c R3 $B/$LAWBIN R11U205_IFARRIDX_OFF=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  [ -z "$m0" ] && return
  echo "$(echo $c | sed "s#.*/tools/probe/##")$([ $el = 1 ] && echo _el) on=$m0 205OFF=$([ "$m1" = "$m0" ] && echo same || echo moves) L205A=$([ "$m2" = "$m0" ] && echo same || echo moves) IFARR=$([ "$m3" = "$m0" ] && echo same || echo moves) L205A==IFARR:$([ "$m2" = "$m3" ] && echo yes || echo NO)"; }
export -f one; export HERE LAWBIN
{ find $REPO/tools/probe/r11u205dec/cases $HERE/../cases/IA \( -name dut.sv -o -name args \) -printf '%h\n'; } | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort
