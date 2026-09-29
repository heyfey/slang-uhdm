#!/bin/bash
# pairs.sh <switch_reach.txt>: for every case-view no single switch restores (two laws fire on it), the switch pairs
# that restore the pristine bytes.  Uses case.sh (fence fail-closed); LAWBIN / PRISBIN as grid.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAWBIN=${LAWBIN:-law.bin}; PRISBIN=${PRISBIN:-pristine.bin}
SW="R11U220_HPVSIDX_OFF R11U220_HPVSCOL_OFF R11U220_HPVSIPS_OFF R11U220_STRSHIFT_OFF R11U220_STRCONT_OFF R11U220_NEWARRCALL_OFF R11U220_NEWARRIDX_OFF R11U220_CLONEIDX_OFF R11U218_QUALSPAN_OFF R11U218_LVIDXPS_OFF R11U218_HPIPSNAME_OFF R11U218_CLONERET_OFF"
grep NONE "$1" | awk '{print $1}' | while read cv; do
  c=${cv%_el}; el=0; [ "$c" != "$cv" ] && el=1
  pm=$(EL=$el bash $HERE/case.sh $HERE/../cases/$c P $B/$PRISBIN | grep -o 'md5=[0-9a-f]*'); found=""
  for a in $SW; do for b in $SW; do [ "$a" \< "$b" ] || continue
    m=$(EL=$el bash $HERE/case.sh $HERE/../cases/$c S $B/$LAWBIN $a=1 $b=1 | grep -o 'md5=[0-9a-f]*'); [ "$m" = "$pm" ] && found="$found $a+$b"
  done; done
  echo "$cv pair:${found:- NONE}"
done
