#!/usr/bin/env bash
# r10uvm88 — pkgvar-bind census of an arm workdir: golden vs pristine (and patched if present)
set -u
D=${1:?}
for t in g pris pat; do
  f=$D/slpp_all/surelog.uhdm; [ $t = pris ] && f=$D/pris.uhdm; [ $t = pat ] && f=$D/pat.uhdm
  [ -f "$f" ] || continue
  echo "---- $t"
  /tmp/r10uvm88_ct88cen "$f" --pkgvar 2>/dev/null |
    sed 's#^[^|]*|##' | awk -F'\t' '{print $1"\t"$2"\t"$4"\t"$8"\t"$9"\t"$10}'
done
