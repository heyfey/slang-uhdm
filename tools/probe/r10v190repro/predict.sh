#!/usr/bin/env bash
# r10v190 — PREDICT the byte movers from the PRISTINE databases alone.
# A database must move iff some enum BASE typespec carries a Typedef_alias
# (it is a clone) AND its range vector is one the pass's gate accepts:
# every bound node a constant / ref_obj / operation, and at least one ref BOUND.
set -u
W=${1:?workdir}; C=/tmp/v190_scratch/ctv190cen
find "$W" -name slang.uhdm | sort | while read -r f; do
  rel=${f#$W/}
  "$C" "$f" p 2>/dev/null | awk -F'\t' '$2=="TDCE" && $6 ~ /^ALIAS:/ && $8 ~ /BOUND/ && $8 !~ /other:/ {n++} END{print n+0}' \
    | while read -r n; do [ "$n" != 0 ] && echo "PREDICT-MOVER $rel cells=$n"; done
done
