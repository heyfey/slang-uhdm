#!/usr/bin/env bash
# r10uvm90 — THE MOVER PREDICTOR.  PRISTINE BYTES ONLY.
#
# The law can only ever turn a NULL `Tf_call_args` vector on a
# `method_func_call` named `new`/`super.new` into a POPULATED one: when
# `constructorCall` is already a `CallExpression` the arm is byte-for-byte what
# it was.  So the predicted mover set is EXACTLY the set of such objects whose
# vector is NULL in the PRISTINE database -- read here off pristine outputs,
# before the patched sweep is looked at.
#
#   usage: pred90.sh <pristine workdir> [<out prefix>]
set -u
WD=${1:?pristine workdir}
OUT=${2:-/tmp/r10uvm90_pred}
CEN=${CEN:-/tmp/r10uvm90_ct90cen}
: > $OUT.rows
: > $OUT.objs
n=0
while IFS= read -r db; do
  d=$(dirname "$db"); row=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  c=$("$CEN" "$db" 2>/dev/null | awk -F'\t' '$4=="NARGS=-1"' | tee -a /tmp/r10uvm90_pred.tmp | wc -l)
  if [ "$c" -gt 0 ]; then
    printf "%s\t%s\t%s\n" "$mode" "$row" "$c" >> $OUT.rows
    "$CEN" "$db" 2>/dev/null | awk -F'\t' -v m="$mode" -v r="$row" '$4=="NARGS=-1"{print m"\t"r"\t"$1"\t"$3}' >> $OUT.objs
  fi
  n=$((n+1))
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases read: $n"
echo "-- rows with >=1 NULL-arg new/super.new: $(wc -l < $OUT.rows)"
echo "-- predicted mover OBJECTS: $(wc -l < $OUT.objs)"
sort -k3 -t'	' $OUT.rows | awk -F'\t' '{s+=$3} END{print "-- total objects (sum): "s}'
