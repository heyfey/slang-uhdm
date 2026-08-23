#!/usr/bin/env bash
# r10vbuvm30 (VERIFIER) adversarial arm driver.
#   golden = Surelog, plus a PRISTINE and a CANDIDATE binary, in BOTH views
#   (default and -elabuhdm), scored with the VIEW-GENERAL cell census
#   (vcells30.py) three ways (vscore30.py):
#     LOST    = a golden-agreeing cell the candidate DESTROYED  (a regression)
#     GAIN    = a golden-agreeing cell the candidate CREATED
#     NEWMINT = a cell the candidate has that neither golden nor pristine has
# MEASUREMENT ONLY.  The official uhdm-cmp remains the judge.
#   PRI=<pristine> PAT=<candidate> [SRCD=<dir of vg30_*.sv>] [WD=<scratch>]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRCD=${SRCD:-$HERE}
PRI=${PRI:?}; PAT=${PAT:?}
WD=${WD:-/tmp/vbuvm30_armwd}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
ls "$SRCD"/vg30_*.sv | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  b=$(basename "$src" .sv)
  for m in def elab; do
    o=$WD/${b}_$m; mkdir -p "$o"; cp "$src" "$o/"; leaf=$(basename "$src")
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && $SL -parse "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 $fl -o g >sl.log 2>&1 </dev/null )
    ( cd "$o" && "$PRI" $fl "$leaf" --single-unit -o pris.uhdm >pris.log 2>&1 </dev/null; echo "rc=$?" >> pris.log )
    ( cd "$o" && "$PAT" $fl "$leaf" --single-unit -o pat.uhdm  >pat.log  2>&1 </dev/null; echo "rc=$?" >> pat.log )
    gu=$o/g/slpp_all/surelog.uhdm
    for t in g:$gu pris:$o/pris.uhdm pat:$o/pat.uhdm; do
      tag=${t%%:*}; f=${t#*:}
      if [ -f "$f" ]; then
        "$DUMP" "$f" 2>/dev/null </dev/null | sed "s#$o##g" > "$o/$tag.dump"
        python3 "$HERE/vcells30.py" "$o/$tag.dump" > "$o/$tag.cells"
      else echo "MISSING-$tag $b/$m"; : > "$o/$tag.cells"; fi
    done
    hp=0; hq=0
    [ -f "$gu" ] && [ -f "$o/pris.uhdm" ] && hp=$($CMP "$gu" "$o/pris.uhdm" 2>&1 </dev/null | grep -c '^LHS:'; true)
    [ -f "$gu" ] && [ -f "$o/pat.uhdm" ]  && hq=$($CMP "$gu" "$o/pat.uhdm"  2>&1 </dev/null | grep -c '^LHS:'; true)
    python3 "$HERE/vscore30.py" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b/$m heads=$hp/$hq"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
