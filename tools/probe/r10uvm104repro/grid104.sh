#!/usr/bin/env bash
# r10uvm104 grid — golden(Surelog) vs pristine vs patched, per arm, BOTH views.
#
# LHS is ALWAYS golden.  The cell key is (owner span, object kind) via the
# uhdm-dump line that carries the STRING value together with the two lines of
# context above it; the score is the multiset of `STRING:` values plus the
# multiset of `vpiDecompile:` values, which is what expr::Compare reads
# (VpiDecompile first, then VpiSize; VpiValue is dump-only but is scored here
# so a half-modelled object cannot hide).
#
#   usage: GRIDWD=<scratch> PRI=<pristine bin> PAT=<patched bin> grid104.sh <arm.sv> ...
set -u
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
WD=${GRIDWD:?}; PRI=${PRI:?}; PAT=${PAT:?}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
printf '%-22s %-5s %-9s %s\n' ARM VIEW VERDICT DETAIL
for src in "$@"; do
  b=$(basename "$src")
  for view in def elab; do
    d=$WD/$b.$view; mkdir -p "$d"; cp "$src" "$d/" || continue
    sopt=(); popt=()
    [ "$view" = elab ] && { sopt=(-elabuhdm); popt=(--elabuhdm); }
    ( cd "$d" && "$SURELOG" -parse -sverilog "${sopt[@]}" "$b" -mt 0 -mp 0 -o out >sl.log 2>&1 </dev/null; echo $? >sl.rc )
    g=$(find "$d/out" -name '*.uhdm' | head -1)
    ( cd "$d" && "$PRI" "${popt[@]}" "$b" -o pris.uhdm >pris.log 2>&1 </dev/null; echo $? >pris.rc )
    ( cd "$d" && "$PAT" "${popt[@]}" "$b" -o pat.uhdm  >pat.log  2>&1 </dev/null; echo $? >pat.rc )
    if [ -z "$g" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
      printf '%-22s %-5s %-9s %s\n' "$b" "$view" MISSING "g=${g:-none} prisrc=$(cat "$d/pris.rc") patrc=$(cat "$d/pat.rc")"
      continue
    fi
    for tag in g pris pat; do
      f=$g; [ $tag = pris ] && f=$d/pris.uhdm; [ $tag = pat ] && f=$d/pat.uhdm
      "$DUMP" "$f" 2>/dev/null | grep -oP '(?<=\|)(STRING:|vpiDecompile:).*' | sort > "$d/$tag.txt"
    done
    a=$(comm -3 "$d/g.txt" "$d/pris.txt" | wc -l)
    c=$(comm -3 "$d/g.txt" "$d/pat.txt" | wc -l)
    v=SAME
    [ "$c" -lt "$a" ] && v=TO-GOLDEN
    [ "$c" -gt "$a" ] && v=AWAY
    [ "$c" = 0 ] && [ "$a" = 0 ] && v=BOTH-EQUAL
    [ "$c" = 0 ] && [ "$a" != 0 ] && v=CLEARED
    printf '%-22s %-5s %-9s %s\n' "$b" "$view" "$v" "pris_unmatched=$a pat_unmatched=$c rc=$(cat "$d/pris.rc")/$(cat "$d/pat.rc")"
  done
done
