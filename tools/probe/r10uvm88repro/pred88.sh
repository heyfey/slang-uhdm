#!/usr/bin/env bash
# r10uvm88 — THE MOVER PREDICTOR, run on PRISTINE bytes ONLY.
#
# § pkgVarBindsOnlyThroughInstance88 removes exactly those `ref_obj`s whose
# `Actual_group` is a PACKAGE-SCOPE variable and whose enclosing task_func has
# NO `vpiInstance` while sitting under a `class_defn` -- i.e. an IN-BODY class
# method.  ct88cen prints both facts (SITEINST=<null>, SITECLS=1), so the mover
# set is READ OFF THE PRISTINE DATABASE, by name, before the patched binary
# exists.  Every database with >=1 such row is predicted to change bytes; every
# database with 0 is predicted BYTE-IDENTICAL.
#
#   usage: pred88.sh <workdir-root>   (a verify_golden.py workdir)
set -u
WD=${1:?workdir root}
CEN=${CEN:-/tmp/r10uvm88_ct88cen}
tot=0; hit=0
while read -r p; do
  tot=$((tot+1))
  n=$("$CEN" "$p" --pkgvar 2>/dev/null |
      grep -c 'SITEINST=<null>.*SITECLS=1' || true)
  if [ "${n:-0}" -gt 0 ]; then
    hit=$((hit+1))
    echo "PRED_MOVER $n ${p#$WD/}"
    "$CEN" "$p" --pkgvar 2>/dev/null | grep 'SITEINST=<null>.*SITECLS=1' |
      sed 's#^[^|]*|##' | awk -F'\t' '{print "    "$2"  "$4"  "$8}' | sort -u
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases=$tot  PREDICTED MOVERS=$hit"
