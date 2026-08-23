#!/usr/bin/env bash
# r10buvm30 — run every g30_*.sv arm under Surelog (golden), the PRISTINE and
# the PATCHED binary, and report, per arm:
#   MOVED  = TOP-package return-expression lines that differ pristine->patched
#   TOGOLD = of those, the ones that now match golden
# MEASUREMENT ONLY.  The official uhdm-cmp remains the judge.
#   PRI=<pristine> PAT=<patched> WD=<scratch> arms30.sh
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?}; PAT=${PAT:?}
WD=${WD:-/tmp/r10buvm30_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
ls "$HERE"/g30_*.sv | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  b=$(basename "$src" .sv); o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/"
  leaf=$(basename "$src")
  ( cd "$o" && "$SURELOG" -parse "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 -o g \
      > sl.log 2>&1 </dev/null )
  ( cd "$o" && "$PRI" "$leaf" --single-unit -o pris.uhdm > pris.log 2>&1 </dev/null )
  ( cd "$o" && "$PAT" "$leaf" --single-unit -o pat.uhdm  > pat.log  2>&1 </dev/null )
  proc=$((proc+1))
  for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
    tag=${w%%:*}; f=$o/${w#*:}
    [ -f "$f" ] || { echo "$b: NO-$tag"; continue; }
    "$DUMP" "$f" 2>/dev/null </dev/null > "$o/$tag.dump"
    t=$(grep -n '^|uhdmtopPackages' "$o/$tag.dump" | head -1 | cut -d: -f1)
    [ -n "$t" ] || t=0
    python3 "$HERE/retcmp30.py" "$o/$tag.dump" "$t" > "$o/$tag.ret" 2>/dev/null
  done
  [ -s "$o/g.ret" ] || { echo "$b: NO-GOLDEN-RETURNS"; continue; }
  moved=$(diff "$o/pris.ret" "$o/pat.ret" | grep -c '^[<>]'; true)
  agr_p=$(diff "$o/g.ret" "$o/pris.ret" | grep -c '^[<>]'; true)
  agr_q=$(diff "$o/g.ret" "$o/pat.ret"  | grep -c '^[<>]'; true)
  echo "$b MOVED=$moved GOLDEN_DIFF pris=$agr_p pat=$agr_q"
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
