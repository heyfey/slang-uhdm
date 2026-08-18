#!/usr/bin/env bash
# Per-arm OFFICIAL uhdm-cmp: golden vs pristine and golden vs patched, BOTH views.
set -u
ARM=$1; W=$2
PRIS=/tmp/vbuvm20_bin/pris.bin; PAT=/tmp/vbuvm20_bin/pat.bin
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
rm -rf "$W"; mkdir -p "$W"
b=$(basename "$ARM" .sv)
for v in d e; do
  mkdir -p "$W/$v/g" "$W/$v/p" "$W/$v/q"
  for d in g p q; do cp "$ARM" "$W/$v/$d/a.sv"; done
  if [ $v = d ]; then SLF=""; OF=""; else SLF="-elabuhdm"; OF="--elabuhdm"; fi
  ( cd "$W/$v/g" && $SURELOG a.sv -parse $SLF -d coveruhdm -nocache -createcache -noprecompiledcache -nowritecache -mt 0 -mp 0 -o s >sl.log 2>&1 ) </dev/null
  ( cd "$W/$v/p" && $PRIS a.sv $OF -o p.uhdm >p.log 2>&1; echo "rc=$?" >>p.log ) </dev/null
  ( cd "$W/$v/q" && $PAT  a.sv $OF -o q.uhdm >q.log 2>&1; echo "rc=$?" >>q.log ) </dev/null
  G="$W/$v/g/s/slpp_all/surelog.uhdm"
  ( $CMP "$G" "$W/$v/p/p.uhdm" > "$W/$v.pris.cmp" 2>&1 ) </dev/null
  ( $CMP "$G" "$W/$v/q/q.uhdm" > "$W/$v.pat.cmp"  2>&1 ) </dev/null
  pl=$(grep -c '' "$W/$v.pris.cmp"); ql=$(grep -c '' "$W/$v.pat.cmp")
  ph=$(grep -c '^LHS:' "$W/$v.pris.cmp"; true); qh=$(grep -c '^LHS:' "$W/$v.pat.cmp"; true)
  pe=$(grep -c 'design is EQUAL\|EQUAL' "$W/$v.pris.cmp"; true); qe=$(grep -c 'design is EQUAL\|EQUAL' "$W/$v.pat.cmp"; true)
  printf '%-14s view=%s  PRIS lines=%-5s heads=%-3s | PAT lines=%-5s heads=%-3s\n' "$b" "$v" "$pl" "$ph" "$ql" "$qh"
done
