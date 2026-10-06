#!/bin/bash
# v11u257 vgrid.sh <out> <case dir>...: every case in both views on pristine (vP), law (vL), fix (vF), fix +
# R11V257_OFF (vFV, must give the law's bytes), fix + R11U257_OFF (vFU, the base's bytes), fix + R11V257_ADDKIND_OFF
# (vFA), fix + R11V257_HCORDER_OFF (vFH), fix + R11V257_CLONETFORDER_OFF (vFC); one r11u257 case.sh line per case-view-configuration, rc= on every line.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do for el in 0 1; do
  EL=$el bash $R257_D/case.sh $c vP $B/pristine | sed 's/^/vP /' >> $out
  EL=$el bash $R257_D/case.sh $c vL $B/law | sed 's/^/vL /' >> $out
  EL=$el bash $R257_D/case.sh $c vF $B/fix | sed 's/^/vF /' >> $out
  EL=$el bash $R257_D/case.sh $c vFV $B/fix R11V257_OFF=1 | sed 's/^/vFV /' >> $out
  EL=$el bash $R257_D/case.sh $c vFU $B/fix R11U257_OFF=1 | sed 's/^/vFU /' >> $out
  EL=$el bash $R257_D/case.sh $c vFA $B/fix R11V257_ADDKIND_OFF=1 | sed 's/^/vFA /' >> $out
  EL=$el bash $R257_D/case.sh $c vFH $B/fix R11V257_HCORDER_OFF=1 | sed 's/^/vFH /' >> $out
  EL=$el bash $R257_D/case.sh $c vFC $B/fix R11V257_CLONETFORDER_OFF=1 | sed 's/^/vFC /' >> $out
done; done
