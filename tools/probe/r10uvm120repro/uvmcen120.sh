#!/usr/bin/env bash
# r10uvm120 — run cen120.py (the a-priori substituted-read census) over the
# GOLDEN and the OUR-SIDE database of every named row of a sweep workdir, and
# report the per-row cell counts and the golden-only / ours-only sets.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#   SW=<sweep workdir> OUT=<dir> uvmcen120.sh <Test> [Test...]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SW=${SW:?}; OUT=${OUT:?}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT"
for m in default testflags; do
  for t in "$@"; do
    d=$(ls -d "$SW/$m/$t"-* 2>/dev/null | head -1)
    [ -n "$d" ] || { echo "$m $t NO-DIR"; continue; }
    g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" | head -1)
    for w in g:"$g/golden.uhdm" o:"$d/slang.uhdm"; do
      tag=${w%%:*}; f=${w#*:}
      c=$OUT/${tag}_${t}_${m}.tsv
      if [ ! -f "$f" ]; then echo "$m $t NO-${tag}"; : > "$c"; continue; fi
      [ -s "$c" ] || {
        "$DUMP" "$f" 2>/dev/null </dev/null > "$OUT/${tag}_${t}_${m}.dump"
        python3 "$HERE/cen120.py" "$OUT/${tag}_${t}_${m}.dump" \
          | sort > "$c"
        rm -f "$OUT/${tag}_${t}_${m}.dump"; }
    done
    gn=$(wc -l < "$OUT/g_${t}_${m}.tsv"); on=$(wc -l < "$OUT/o_${t}_${m}.tsv")
    # key on view+kind+span+param_assign span+value (drop the ancestor chain)
    cut -f1-7 "$OUT/g_${t}_${m}.tsv" | sort > "$OUT/gk.$$"
    cut -f1-7 "$OUT/o_${t}_${m}.tsv" | sort > "$OUT/ok.$$"
    only_g=$(comm -23 "$OUT/gk.$$" "$OUT/ok.$$" | wc -l)
    only_o=$(comm -13 "$OUT/gk.$$" "$OUT/ok.$$" | wc -l)
    comm -23 "$OUT/gk.$$" "$OUT/ok.$$" > "$OUT/onlyg_${t}_${m}.tsv"
    comm -13 "$OUT/gk.$$" "$OUT/ok.$$" > "$OUT/onlyo_${t}_${m}.tsv"
    rm -f "$OUT/gk.$$" "$OUT/ok.$$"
    echo "$m $t GOLDEN_CELLS=$gn OUR_CELLS=$on ONLY_GOLDEN=$only_g ONLY_OURS=$only_o"
  done
done
