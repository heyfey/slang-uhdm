#!/bin/bash
# r11u29repro/quote_cluster.sh — quote a cluster's heads SIDE BY SIDE, id-blind.
#
# A cluster claim of a SHARED face is only worth reading with the heads
# themselves under it.  This prints, for every row of one cluster, the official
# uhdm-cmp head with ids and source locations blinded, so two rows that carry
# the same producer fact can be read as the same text.
#
#   usage: quote_cluster.sh <CLUSTERS.tsv> <cluster> <cmpdir> [<cmpdir2> ...]
#          (cmpdir = the survey.sh <outdir>/cmp holding <row>.<mode>.cmp)
set -u
TSV=${1:?clusters tsv}; CL=${2:?cluster}; shift 2
echo "==== CLUSTER $CL — $(grep -c "	$CL	" "$TSV") rows"
grep "	$CL	" "$TSV" | while IFS=$'\t' read -r corpus row cl face; do
  echo
  echo "---- $corpus/$row   FACE: $face"
  for d in "$@"; do
    for f in "$d/$row".*.cmp; do
      [ -f "$f" ] || continue
      case "$f" in *.testflags.cmp) continue;; esac   # modes proven identical
      sed -E 's/id:[0-9]+/id:#/g; s/line:[0-9]+:[0-9]+/line:#/g; s/endln:[0-9]+:[0-9]+/endln:#/g; s#file:[^,]*#file:#' "$f" \
        | awk '/^LHS:/{p=1} p&&n<44{print "    "$0; n++}'
    done
  done
done
