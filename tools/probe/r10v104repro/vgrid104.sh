#!/usr/bin/env bash
# r10uvm104 VERIFIER grid — golden(Surelog) vs pristine vs patched, BOTH views.
# Scores the WHOLE uhdm-dump, path-normalised and order-blind (not just the
# STRING:/vpiDecompile: lines the implementer scored), so collateral moves in
# any other field cannot hide.  Also reports the narrow string-only score.
# rc recorded per cell.  LHS is ALWAYS golden.
set -u
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
WD=${GRIDWD:?}; PRI=${PRI:?}; PAT=${PAT:?}
mkdir -p "$WD" || exit 9
printf '%-26s %-5s %-10s %s\n' ARM VIEW VERDICT DETAIL
for src in "$@"; do
  b=$(basename "$src")
  for view in def elab; do
    d=$WD/$b.$view; rm -rf "$d"; mkdir -p "$d"; cp "$src" "$d/" || continue
    sopt=(); popt=()
    [ "$view" = elab ] && { sopt=(-elabuhdm); popt=(--elabuhdm); }
    ( cd "$d" && "$SURELOG" -parse -sverilog "${sopt[@]}" "$b" -mt 0 -mp 0 -o out >sl.log 2>&1 </dev/null; echo $? >sl.rc )
    g=$(find "$d/out" -name '*.uhdm' | head -1)
    ( cd "$d" && "$PRI" "${popt[@]}" "$b" -o pris.uhdm >pris.log 2>&1 </dev/null; echo $? >pris.rc )
    ( cd "$d" && "$PAT" "${popt[@]}" "$b" -o pat.uhdm  >pat.log  2>&1 </dev/null; echo $? >pat.rc )
    prc=$(cat "$d/pris.rc"); parc=$(cat "$d/pat.rc"); src_=$(cat "$d/sl.rc")
    if [ -z "$g" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
      printf '%-26s %-5s %-10s %s\n' "$b" "$view" MISSING "g=${g:-none} slrc=$src_ prisrc=$prc patrc=$parc"
      continue
    fi
    for tag in g pris pat; do
      f=$g; [ $tag = pris ] && f=$d/pris.uhdm; [ $tag = pat ] && f=$d/pat.uhdm
      "$DUMP" "$f" 2>/dev/null | sed -e "s|$d/||g" -e "s|$WD/||g" -e 's|/tmp/[A-Za-z0-9_.]*/||g' | sort > "$d/$tag.full"
      grep -oP '(?<=\|)(STRING:|vpiDecompile:).*' "$d/$tag.full" | sort > "$d/$tag.str"
    done
    aF=$(comm -3 "$d/g.full" "$d/pris.full" | wc -l); cF=$(comm -3 "$d/g.full" "$d/pat.full" | wc -l)
    aS=$(comm -3 "$d/g.str"  "$d/pris.str" | wc -l); cS=$(comm -3 "$d/g.str"  "$d/pat.str" | wc -l)
    pp=$(comm -3 "$d/pris.full" "$d/pat.full" | wc -l)
    v=SAME
    [ "$cF" -lt "$aF" ] && v=TO-GOLDEN
    [ "$cF" -gt "$aF" ] && v=AWAY
    [ "$cF" = 0 ] && [ "$aF" = 0 ] && v=BOTH-EQUAL
    [ "$cF" = 0 ] && [ "$aF" != 0 ] && v=CLEARED
    printf '%-26s %-5s %-10s %s\n' "$b" "$view" "$v" "full pris=$aF pat=$cF | str pris=$aS pat=$cS | prisVpat=$pp | rc s=$src_ p=$prc P=$parc"
  done
done
