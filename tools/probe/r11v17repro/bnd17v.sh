#!/usr/bin/env bash
# v11u17 INDEPENDENT boundary: compile a file list with BOTH frozen binaries,
# normalise (workdir path, object ids, the output filename) and compare
# ORDER-BLIND.  List read on fd 3, children </dev/null, PROCESSED==LISTED.
set -u
LIST=${1:?file list}
OUT=${OUT:-/tmp/v11u17_bndout}
PRIS=${PRIS:-/tmp/v11u17_bin/pris.bin}
LAW=${LAW:-/tmp/v11u17_bin/law.bin}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
rm -rf "$OUT"; mkdir -p "$OUT"
LISTED=$(grep -c . "$LIST"; true); PROCESSED=0; MOVED=0
exec 3< "$LIST"
while read -r f <&3; do
  [ -n "$f" ] || continue
  PROCESSED=$((PROCESSED+1))
  key=$(echo "$f" | sed 's#[/.]#_#g')
  d="$OUT/$key"; mkdir -p "$d"
  for tag in pris law; do
    b=$PRIS; [ $tag = law ] && b=$LAW
    "$b" "$f" --single-unit --nobuiltin -o "$d/$tag.uhdm" > "$d/$tag.log" 2>&1 </dev/null
    echo "rc_$tag=$?" >> "$d/rc.txt"
    if [ -f "$d/$tag.uhdm" ]; then
      "$DUMP" "$d/$tag.uhdm" 2>&1 </dev/null | sed -e "s#$d/##g" -e 's/, id:[0-9]*//g' -e 's/^.*Restored design.*$//' -e 's/\(pris\|law\)\.uhdm//g' | sort > "$d/$tag.n"
    fi
  done
  if [ -f "$d/pris.n" ] && [ -f "$d/law.n" ]; then
    n=$(diff "$d/pris.n" "$d/law.n" | grep -c '^[<>]'; true)
    if [ "$n" != "0" ]; then MOVED=$((MOVED+1)); echo "MOVER $f norm_delta=$n rc=$(tr '\n' ' ' < $d/rc.txt)"; fi
  else
    echo "NODB  $f rc=$(tr '\n' ' ' < $d/rc.txt)"
  fi
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROCESSED MOVED=$MOVED"
[ "$LISTED" = "$PROCESSED" ] && echo "ASSERT PROCESSED==LISTED OK" || echo "ASSERT FAILED"
