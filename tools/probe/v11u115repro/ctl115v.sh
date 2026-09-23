#!/bin/bash
# ctl115v.sh <out-root> <binP> <binL> <binF> <dir>...: CONTROL byte-compare over earlier passes'
# arms, THREE binaries (pristine / implementer LAW / verifier FIX).  Every *.sv under each <dir>
# is compiled alone by each binary in both forms (--single-unit --nobuiltin [+ --elabuhdm]) from
# its own directory; prints "<PL> <PF> <LF> <form> <file> rcP rcL rcF" with SAME/DIFF/RC per pair.
OUT=${1:?out}; P=${2:?binP}; L=${3:?binL}; F=${4:?binF}; shift 4
mkdir -p "$OUT"; n=0
LIST=$(mktemp "$OUT/list.XXXX"); for d in "$@"; do find "$d" -name '*.sv' | sort; done > "$LIST"
pair() { if [ ! -f "$1" ] || [ ! -f "$2" ]; then echo RC; elif cmp -s "$1" "$2"; then echo SAME; else echo DIFF; fi; }
while read -r f <&3; do
  key=$(echo "$f" | sed 's#[/.]#_#g'); dir=$(dirname "$f"); base=$(basename "$f")
  for form in u2r elab; do
    ex=(); [ $form = elab ] && ex=(--elabuhdm)
    for t in P L F; do b=${!t}; rm -f "$OUT/$key.$form.$t.uhdm"
      (cd "$dir" && timeout 300 "$b" "${ex[@]}" "$base" --single-unit --nobuiltin -o "$OUT/$key.$form.$t.uhdm" </dev/null >/dev/null 2>&1); eval rc$t=$?; done
    n=$((n+1))
    echo "$(pair $OUT/$key.$form.P.uhdm $OUT/$key.$form.L.uhdm) $(pair $OUT/$key.$form.P.uhdm $OUT/$key.$form.F.uhdm) $(pair $OUT/$key.$form.L.uhdm $OUT/$key.$form.F.uhdm) $form $f $rcP $rcL $rcF"
  done
done 3< "$LIST"
echo "PROCESSED=$n LISTED=$(( $(wc -l < "$LIST") * 2 ))"
rm -f "$LIST"
