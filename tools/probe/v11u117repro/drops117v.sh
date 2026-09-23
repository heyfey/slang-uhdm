#!/bin/bash
# v11u117 drops: per arm-form, dump text of vfix under each switch vs pris / lawx / vfix
OUT=${OUT:?out dir}; mkdir -p $OUT
P=${P:?pristine bin}; L=${L:?implementer law bin}; V=${V:?verified bin}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
LIST=$(mktemp $OUT/list.XXXX); for g in "$@"; do find "$g" -name dut.sv | sort; done > $LIST
dmp(){ $DUMP "$1" 2>&1 | tail -n +2 | sed -E "s#$OUT/[^ ,]*##g" > "$1.dmp"; }
declare -A ne_p ne_l ne_v; n=0; rcbad=0
SW="NONE R11U117_OFF R11U117_OVR_OFF R11U117_QSEL_OFF R11U117_BITS_OFF R11U117_QSELREF_OFF"
while read -r f <&3; do
  d=$(dirname "$f"); k=$(echo "$d" | sed 's#^/tmp/##; s#/#_#g')
  for form in tf def; do
    if [ $form = tf ]; then fl=(--single-unit --nobuiltin); else fl=(--single-unit); fi
    n=$((n+1))
    for t in pri law; do b=$P; [ $t = law ] && b=$L; (cd "$d" && "$b" dut.sv "${fl[@]}" -o "$OUT/$k.$form.$t" </dev/null >/dev/null 2>&1) || rcbad=$((rcbad+1)); dmp "$OUT/$k.$form.$t"; done
    for sw in $SW; do
      o="$OUT/$k.$form.s_$sw"
      if [ $sw = NONE ]; then (cd "$d" && "$V" dut.sv "${fl[@]}" -o "$o" </dev/null >/dev/null 2>&1) || rcbad=$((rcbad+1))
      else (cd "$d" && env $sw=1 "$V" dut.sv "${fl[@]}" -o "$o" </dev/null >/dev/null 2>&1) || rcbad=$((rcbad+1)); fi
      dmp "$o"
      cmp -s "$o.dmp" "$OUT/$k.$form.pri.dmp" || { ne_p[$sw]=$((${ne_p[$sw]:-0}+1)); }
      cmp -s "$o.dmp" "$OUT/$k.$form.law.dmp" || { ne_l[$sw]=$((${ne_l[$sw]:-0}+1)); [ $sw = R11U117_OVR_OFF ] && echo "OVROFF_NE_LAW $k.$form"; }
      cmp -s "$o.dmp" "$OUT/$k.$form.s_NONE.dmp" || ne_v[$sw]=$((${ne_v[$sw]:-0}+1))
      [ $sw = R11U117_OFF ] && ! cmp -s "$o.dmp" "$OUT/$k.$form.pri.dmp" && echo "OFF_NE_PRIS $k.$form"
    done
  done
done 3< $LIST
echo "ARMFORMS=$n LISTED=$(wc -l < $LIST) RCBAD=$rcbad"
for sw in $SW; do echo "$sw  differs_from_PRIS=${ne_p[$sw]:-0} differs_from_LAW=${ne_l[$sw]:-0} differs_from_VFIX=${ne_v[$sw]:-0}"; done
