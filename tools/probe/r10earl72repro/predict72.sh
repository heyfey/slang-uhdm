#!/usr/bin/env bash
# r10earl72 — PREDICT the byte movers of § caOpFoldElabTs72 from the PRISTINE
# databases, BEFORE the patched sweep is scored (RESUME §7).
#
# The candidate shape, read straight off the law: a constant that sits inside an
# ELABORATED cont_assign RHS (its VpiParent chain carries a NAMED module_inst or
# a gen_scope, i.e. it is not the def listing), with at least one OPERATION
# between it and the cont_assign, carrying NO typespec — AND whose DEF-listing
# twin at the SAME span and the SAME positional path DOES carry one.  That pair
# is exactly what the patch turns into a stamp; a database with no such pair
# cannot move a byte.
#
# MEASUREMENT ONLY.  usage: predict72.sh <sweep-workdir> <tscen72-binary>
set -u
W=${1:?sweep workdir}; CEN=${2:?tscen72 binary}
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 9; }
n=0; hit=0
while IFS= read -r db; do
  n=$((n+1))
  R66_INST=1 "$CEN" "$db" 2>/dev/null | grep ' constant ' | awk '
    $3 ~ /^CA_/ {
      path=$4; span=""; ts="-";
      for (i=5;i<=NF;i++) { if ($i ~ /^span=/) span=substr($i,6); if ($i ~ /^ts=/) ts=substr($i,4); }
      elab = ($2 ~ /module_inst\(/ || $2 ~ /gen_scope/);
      hasop = (path ~ /\/op[0-9]/);
      if (!hasop) next;
      key = span "|" path;
      if (elab && ts == "-") bare[key]++;
      if (!elab && ts != "-") stamped[key]++;
    }
    END { c=0; for (k in bare) if (k in stamped) c += bare[k]; print c }' > /tmp/.r10earl72_p.$$
  c=$(cat /tmp/.r10earl72_p.$$); rm -f /tmp/.r10earl72_p.$$
  [ "${c:-0}" -gt 0 ] 2>/dev/null && { hit=$((hit+1)); echo "CAND $c ${db#$W/}"; }
done < <(find "$W" -name 'slang.uhdm' | sort)
echo "SCANNED $n databases, $hit carry a candidate"
