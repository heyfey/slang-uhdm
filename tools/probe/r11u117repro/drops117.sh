#!/bin/bash
# drops117.sh <out> <pristine> <law> <grid-dir>... — every law droppable alone:
# for each switch, compile every arm (both forms) with the LAW binary under the
# switch and count arm-forms whose bytes differ from the LAW's own (moved by
# the switch) and from PRISTINE (still moved).  Output names are SAME-LENGTH
# (.pri/.law/.swx).  Arm-forms are compared by uhdm-dump TEXT (first line
# dropped): the database BYTES of a flat-pattern arm vary run to run on the
# PRISTINE binary too (g19/t03 measured), a dump-invisible class.  R11U117_OFF must give
# pristine everywhere.
OUT=${1:?}; P=${2:?}; L=${3:?}; shift 3
mkdir -p "$OUT"
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
LIST=$(mktemp "$OUT/list.XXXX"); for g in "$@"; do find "$g" -name dut.sv | sort; done > "$LIST"
for sw in NONE R11U117_OFF R11U117_QSEL_OFF R11U117_BITS_OFF R11U117_QSELREF_OFF; do
  n=0; vsl=0; vsp=0; moved=""
  while read -r f <&3; do
    d=$(dirname "$f"); k=$(echo "$d" | sed 's#.*/grid/##; s#/#_#g')
    for form in tf def; do
      if [ $form = tf ]; then fl=(--single-unit --nobuiltin); else fl=(--single-unit); fi
      [ -f "$OUT/$k.$form.pri" ] || (cd "$d" && "$P" dut.sv "${fl[@]}" -o "$OUT/$k.$form.pri" </dev/null >/dev/null 2>&1)
      [ -f "$OUT/$k.$form.law" ] || (cd "$d" && "$L" dut.sv "${fl[@]}" -o "$OUT/$k.$form.law" </dev/null >/dev/null 2>&1)
      if [ $sw = NONE ]; then cp "$OUT/$k.$form.law" "$OUT/$k.$form.swx"
      else (cd "$d" && env $sw=1 "$L" dut.sv "${fl[@]}" -o "$OUT/$k.$form.swx" </dev/null >/dev/null 2>&1); fi
      n=$((n+1))
      for t in pri law swx; do [ "$OUT/$k.$form.$t.dmp" -nt "$OUT/$k.$form.$t" ] || $DUMP "$OUT/$k.$form.$t" 2>&1 | tail -n +2 > "$OUT/$k.$form.$t.dmp"; done
      cmp -s "$OUT/$k.$form.swx.dmp" "$OUT/$k.$form.law.dmp" || { vsl=$((vsl+1)); moved="$moved $k.$form"; }
      cmp -s "$OUT/$k.$form.swx.dmp" "$OUT/$k.$form.pri.dmp" || vsp=$((vsp+1))
    done
  done 3< "$LIST"
  echo "$sw armforms=$n differs_from_LAW=$vsl differs_from_PRISTINE=$vsp"
  echo "   moved:$moved" | cut -c1-600
done
