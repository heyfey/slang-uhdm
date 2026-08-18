#!/usr/bin/env bash
# r10uvm90 — THE MOVER PREDICTION, SHARPENED.  PRISTINE + GOLDEN bytes only; the
# patched sweep is NOT read.
#
# pred90.sh's `NARGS=-1` population (2165 objects over 17 rows) is the CANDIDATE
# set, not the mover set: most argument-less `new` objects are argument-less in
# GOLDEN too (`h = new;`, `super.new()`).  The objects the law can actually move
# are the ones golden gives a POPULATED vector and we give a NULL one — the
# `ARGS-NULL-OURS` class of join90.py — so this driver runs that join per
# candidate row and prints the predicted mover count BY ROW and BY OWNER NAME.
#
#   usage: pred90b.sh <pristine workdir> <rows file from pred90.sh> <out prefix>
set -u
WD=${1:?pristine workdir}
ROWS=${2:?pred90 .rows}
OUT=${3:-/tmp/r10uvm90_predb}
CEN=${CEN:-/tmp/r10uvm90_ct90cen}
HERE=$(cd "$(dirname "$0")" && pwd)
: > $OUT.byrow; : > $OUT.byname
while IFS=$'\t' read -r mode row cnt; do
  d=$WD/$mode/$row
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ]; then
    printf "%s\t%s\tSKIP-NOFILE\n" "$mode" "$row" >> $OUT.byrow; continue
  fi
  "$CEN" "$G" --all 2>/dev/null | sort > /tmp/r10uvm90_pb_g.cen
  "$CEN" "$d/slang.uhdm" --all 2>/dev/null | sort > /tmp/r10uvm90_pb_o.cen
  python3 "$HERE/join90.py" /tmp/r10uvm90_pb_g.cen /tmp/r10uvm90_pb_o.cen > /tmp/r10uvm90_pb.txt
  n=$(grep -c '^ARGS-NULL-OURS' /tmp/r10uvm90_pb.txt; true)
  printf "%s\t%s\tARGS-NULL-OURS=%s\t%s\n" "$mode" "$row" "$n" \
    "$(tail -1 /tmp/r10uvm90_pb.txt)" >> $OUT.byrow
  grep '^ARGS-NULL-OURS' /tmp/r10uvm90_pb.txt |
    awk -v m="$mode" -v r="$row" '{print m"\t"r"\t"$2"\t"$3}' >> $OUT.byname
done < "$ROWS"
cat $OUT.byrow
echo "-- predicted MOVER OBJECTS (golden-populated, ours-null): $(wc -l < $OUT.byname)"
echo "-- predicted MOVER ROWS: $(awk -F'\t' '$3!="ARGS-NULL-OURS=0" && $3!="SKIP-NOFILE"' $OUT.byrow | wc -l)"
