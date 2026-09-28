#!/bin/bash
# v11u198: order-blind distance (sorted dump lines, ids and paths stripped) golden vs ours, pristine and law, one judged case.
c=$1; h=$(echo "$c${ELAB:+E}" | md5sum | cut -c1-10)
nz() { sed -E 's/, id:[0-9]+//; s#/tmp/[^ ]*##g; s/^ +//' "$1" | grep -v 'Restored design' | sort; }
for b in pris ${LB:-law}; do d=/tmp/v11u198_judge/$b/$h; printf '%s=%s ' $b $(diff <(nz $d/g.dump) <(nz $d/o.dump) | grep -c '^[<>]'); done; echo " $c"
