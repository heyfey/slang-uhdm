#!/usr/bin/env bash
# r10uvm117repro/goldcen117.sh — GOLDEN-VS-GOLDEN CALIBRATION, run BEFORE any
# golden-vs-ours number is read (RESUME §9).  MEASUREMENT ONLY.
#
#   goldcen117.sh <sweep workdir> <cen bin> <outdir> <name> [<name> ...]
#
# For the UVM tests that have BOTH modes, `default` and `testflags` are two
# INDEPENDENT Surelog runs of the same design.  This censuses both goldens with
# ct117cen and compares this family's rows — the IMPLICIT NETS per module and
# the `ref_var` LOCALS of free package subroutines.  EXPM_N is the number of
# pairs that differ; every golden-vs-ours number in this pass is read against
# it.
set -u
W=${1:?workdir}; CEN=${2:?cen bin}; OUT=${3:?outdir}; shift 3
mkdir -p "$OUT"; pairs=0; skip=0; differ=0
for n in "$@"; do
  gd=""; gt=""
  for mode in default testflags; do
    for d in "$W/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      c="$d/cmds.txt"; [ -f "$c" ] || continue
      g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
      [ -n "$g" ] && [ -d "$g" ] && g=$g/golden.uhdm || g=""
      [ "$mode" = default ] && gd=$g || gt=$g
    done
  done
  if [ -z "$gd" ] || [ -z "$gt" ] || [ ! -f "$gd" ] || [ ! -f "$gt" ]; then
    echo "SKIP $n (default=${gd:-none} testflags=${gt:-none})"; skip=$((skip+1)); continue
  fi
  pairs=$((pairs+1))
  "$CEN" "$gd" G | awk -F'\t' '($2=="NET" && $4=="IMPL"){print $2,$3,$5,$6,$7} ($2=="RV" && $5=="PKG"){print $2,$3,$4,$6,$7}' | sort > "$OUT/$n.def.fam"
  "$CEN" "$gt" G | awk -F'\t' '($2=="NET" && $4=="IMPL"){print $2,$3,$5,$6,$7} ($2=="RV" && $5=="PKG"){print $2,$3,$4,$6,$7}' | sort > "$OUT/$n.tf.fam"
  if cmp -s "$OUT/$n.def.fam" "$OUT/$n.tf.fam"; then
    echo "SAME $n ($(wc -l < "$OUT/$n.def.fam") family rows)"
  else
    differ=$((differ+1)); echo "DIFFER $n"; diff "$OUT/$n.def.fam" "$OUT/$n.tf.fam" | head -20
  fi
done
echo "CALIBRATED pairs=$pairs SKIP=$skip EXPM_N=$differ"
