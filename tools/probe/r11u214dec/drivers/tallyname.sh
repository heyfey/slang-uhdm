#!/bin/bash
# tallyname.sh <sweep workdir> <mode> <pattern> <test>...: for each (non-fenced) corpus row of a sweep, the multiset of
# raw full names of ref_typespec records whose canonical full name matches <pattern>, golden (a) vs ours (b), from
# strictcmp_x record dumps (15th column). Needs env.sh (FENCED, B, S).
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "tallyname.sh: source drivers/env.sh" >&2; exit 2; }
W=$1; m=$2; P=$3; shift 3
for t in "$@"; do
  for f in $FENCED; do [ "$f" = "$t" ] && continue 2; done
  d=$(ls -d $W/surelog/$m/$t-* $W/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
  g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1); gd=$HOME/.cache/slang-uhdm-goldens/${g#goldens/}
  x=$S/tally.$$; $B/strictcmp_x --max 0 --dump-a $x.a --dump-b $x.b $gd/golden.uhdm $d/slang.uhdm > /dev/null 2>&1
  for s in a b; do awk -F'\t' -v P="$P" -v S=$s '$2=="ref_typespec" && $5 ~ P {split($15,x,"\x1f"); print S"\t"x[1]}' $x.$s | sort | uniq -c | sed "s#^#$t/$m #"; done
  rm -f $x.a $x.b
done
