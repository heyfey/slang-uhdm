#!/bin/bash
# ctl112.sh <out-root> <binA> <binB> <dir>...: CONTROL byte-compare.  Every *.sv file under
# each <dir> (subdirs included) is compiled ALONE by both binaries in both forms
# (--single-unit --nobuiltin, and --elabuhdm), from the file's own directory; the two
# databases are compared byte for byte.  Prints "SAME|DIFF|RC <form> <file> rcA rcB" and a
# summary; a DIFF also records the uhdm-dump line distance (order-blind, path-normalised).
OUT=${1:?out}; A=${2:?binA}; B=${3:?binB}; shift 3
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"; n=0; same=0; diff=0
LIST=$(mktemp "$OUT/list.XXXX"); for d in "$@"; do find "$d" -name '*.sv' | sort; done > "$LIST"
while read -r f <&3; do
  key=$(echo "$f" | sed 's#[/.]#_#g'); dir=$(dirname "$f"); base=$(basename "$f")
  for form in u2r elab; do
    ex=(); [ $form = elab ] && ex=(--elabuhdm)
    (cd "$dir" && timeout 300 "$A" "${ex[@]}" "$base" --single-unit --nobuiltin -o "$OUT/$key.$form.A.uhdm" </dev/null >/dev/null 2>&1); ra=$?
    (cd "$dir" && timeout 300 "$B" "${ex[@]}" "$base" --single-unit --nobuiltin -o "$OUT/$key.$form.B.uhdm" </dev/null >/dev/null 2>&1); rb=$?
    n=$((n+1))
    if [ ! -f "$OUT/$key.$form.A.uhdm" ] || [ ! -f "$OUT/$key.$form.B.uhdm" ]; then echo "RC $form $f $ra $rb"; continue; fi
    if cmp -s "$OUT/$key.$form.A.uhdm" "$OUT/$key.$form.B.uhdm"; then same=$((same+1)); echo "SAME $form $f $ra $rb"
    else diff=$((diff+1))
      d=$(diff <($DUMP "$OUT/$key.$form.A.uhdm" 2>&1 | tail -n +2 | sed "s#$OUT[^ ]*##g" | sort) <($DUMP "$OUT/$key.$form.B.uhdm" 2>&1 | tail -n +2 | sed "s#$OUT[^ ]*##g" | sort) | grep -c '^[<>]'; true)
      echo "DIFF $form $f $ra $rb orderblind=$d"; fi
  done
done 3< "$LIST"
echo "PROCESSED=$n LISTED=$(( $(wc -l < "$LIST") * 2 )) SAME=$same DIFF=$diff"
rm -f "$LIST"
