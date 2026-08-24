#!/usr/bin/env bash
# r10uvm120 — run every g120_*.sv arm under Surelog (golden), the PRISTINE and
# (optionally) the PATCHED binary and report, per arm, the return-expression
# cells that MOVED and whether they moved TO GOLDEN.  MEASUREMENT ONLY; the
# official uhdm-cmp is the judge.
#   PRI=<pristine> [PAT=<patched>] [WD=<scratch>] arms120.sh
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?}; PAT=${PAT:-}
WD=${WD:-/tmp/r10uvm120_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
ls "$HERE"/g120_*.sv | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  b=$(basename "$src" .sv); o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/"
  leaf=$(basename "$src")
  ( cd "$o" && "$SURELOG" -parse "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 -o g \
      > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
  ( cd "$o" && "$PRI" "$leaf" --single-unit -o pris.uhdm > pris.log 2>&1 </dev/null )
  echo "rc_pris=$?" >> "$o/rcs"
  if [ -n "$PAT" ]; then
    ( cd "$o" && "$PAT" "$leaf" --single-unit -o pat.uhdm > pat.log 2>&1 </dev/null )
    echo "rc_pat=$?" >> "$o/rcs"
  fi
  proc=$((proc+1))
  for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
    tag=${w%%:*}; f=$o/${w#*:}
    [ "$tag" = pat ] && [ -z "$PAT" ] && continue
    [ -f "$f" ] || { echo "$b: NO-$tag"; continue; }
    "$DUMP" "$f" 2>/dev/null </dev/null > "$o/$tag.dump"
    python3 "$HERE/rets120.py" "$o/$tag.dump" > "$o/$tag.ret" 2>"$o/$tag.err"
  done
  [ -s "$o/g.ret" ] || { echo "$b: NO-GOLDEN-RETURNS $(cat "$o/rcs" | tr '\n' ' ')"; continue; }
  gp=$(diff "$o/g.ret" "$o/pris.ret" | grep -c '^[<>]'; true)
  if [ -n "$PAT" ]; then
    mv=$(diff "$o/pris.ret" "$o/pat.ret" | grep -c '^[<>]'; true)
    gq=$(diff "$o/g.ret" "$o/pat.ret" | grep -c '^[<>]'; true)
    echo "$b MOVED=$mv GOLDEN_DIFF pris=$gp pat=$gq $(cat "$o/rcs" | tr '\n' ' ')"
  else
    echo "$b GOLDEN_DIFF pris=$gp $(cat "$o/rcs" | tr '\n' ' ')"
  fi
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
