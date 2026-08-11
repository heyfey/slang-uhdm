#!/usr/bin/env bash
# r10svs2 — the CELL TABLE for arm s7 (§ parensLessFuncRefIsRefObj).
#
# svcells.py reads the SECOND PATH ELEMENT of a dotted-call hier_path and so is
# blind to arm s7, whose sites are RECEIVER-LESS and therefore have no hier_path
# at all.  s7's cell is the OBJECT ITSELF, keyed on name+span with the dump's
# indentation STRIPPED -- the campaign law that "an object is NOT a dump
# occurrence": the same object prints at several depths and keying on the raw
# dump line would count it several times.  `sort -u` after the strip is what
# collapses those depths back to one cell.
#
#   usage: ./svrecv.sh <armdir>        # armdir holds g.dump and o.dump
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
set -u
D=${1:?arm dir holding g.dump and o.dump}
[ -s "$D/g.dump" ] || { echo "FATAL: no $D/g.dump"; exit 3; }
[ -s "$D/o.dump" ] || { echo "FATAL: no $D/o.dump"; exit 3; }
pick() {
  sed 's/^[ \\_|]*//' "$1" \
    | grep -E '^(func_call|task_call|ref_obj|method_func_call): \(' \
    | grep -E "$2" | sort -u
}
PAT=${PAT:-'zero|\(one\)|void_t'}
echo "==== GOLDEN (LHS) objects matching /$PAT/"
pick "$D/g.dump" "$PAT"
echo "==== OURS (RHS) objects matching /$PAT/"
pick "$D/o.dump" "$PAT"
g=$(pick "$D/g.dump" "$PAT" | wc -l)
o=$(pick "$D/o.dump" "$PAT" | wc -l)
same=$(comm -12 <(pick "$D/g.dump" "$PAT") <(pick "$D/o.dump" "$PAT") | wc -l)
echo "==== CELLS golden=$g ours=$o IDENTICAL=$same DIFFERING=$((g - same))"
