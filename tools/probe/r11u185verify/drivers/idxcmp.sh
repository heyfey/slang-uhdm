#!/bin/bash
# idxcmp.sh <GW case dir>...: the index-parent census (r11u178repro/drivers/idxpar.cpp, built to /tmp/r11u185_bin/idxpar)
# of golden and of every state database of a case, compared order-blind: per state, the census lines (element
# position, index kind, index parent kind; the full name dropped) that differ from golden's (ours-not-golden +
# golden-not-ours).  Cases only; fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "idxcmp.sh: source drivers/env.sh" >&2; exit 2; }
for d in "$@"; do
  g=$(ls $d/gold_*/golden.uhdm 2>/dev/null | head -1); [ -n "$g" ] || continue
  /tmp/r11u185_bin/idxpar $g | awk '{$4=""; print}' | sort > /tmp/r11u185_idx.g
  out="${d#/tmp/r11u185_g/}"
  for t in on off_hierPathSelIdxCloneKeepsElem178v off_hierPathSelIdxAtPath178 alloff; do
    [ -f $d/$t.uhdm ] || continue
    /tmp/r11u185_bin/idxpar $d/$t.uhdm | awk '{$4=""; print}' | sort > /tmp/r11u185_idx.o
    out="$out ${t/off_hierPathSelIdxCloneKeepsElem178v/offV}:$(comm -3 /tmp/r11u185_idx.g /tmp/r11u185_idx.o | wc -l)"
  done; echo "$out"
done
