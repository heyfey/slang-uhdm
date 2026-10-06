#!/bin/bash
# v11u262 switches.sh <case dir>...: $B/fix with R11U262_OFF (must give pristine bytes) and with each refinement's
# switch off alone (R11V262_HDRLIST_OFF, R11V262_SAMEDECL_OFF, R11V262_LOOPOPND_OFF), both views.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
for c in "$@"; do c=$(realpath $c); for el in 0 1; do
 EL=$el bash $D/case.sh $c FUOFF $B/fix R11U262_OFF=1
 for s in R11V262_HDRLIST_OFF R11V262_SAMEDECL_OFF R11V262_LOOPOPND_OFF; do EL=$el bash $D/case.sh $c F_$s $B/fix $s=1; done
done; done
