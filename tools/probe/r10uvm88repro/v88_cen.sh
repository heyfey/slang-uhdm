#!/usr/bin/env bash
# v88 — the pkgvar-bind census of an arm workdir, three-way.
set -u
D=${1:?}
CEN=${CEN:-/tmp/v88_ct88cen}
MODE=${MODE:---pkgvar}
for t in g pris pat; do
  f=$D/slpp_all/surelog.uhdm; [ $t = pris ] && f=$D/pris.uhdm; [ $t = pat ] && f=$D/pat.uhdm
  [ -f "$f" ] || continue
  echo "---- $t"
  "$CEN" "$f" $MODE 2>/dev/null | sed 's#^[^|]*|##' |
    awk -F'\t' '{print $1"\t"$2"\t"$3"\t"$4"\t"$8"\t"$9"\t"$10}'
done
