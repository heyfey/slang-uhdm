#!/bin/bash
# lawfix.sh <out tsv> <casedir>...: the byte reach of fix.patch on case directories, both views: the law binary
# ($LAW, 4a620bd0), the fix binary ($FIX) with R11V226_TRACE, and the fix binary under R11V226_OFF=1, each through
# drivers/case.sh (golden, uhdm-cmp, uhdm-strictcmp).  Per case-view: law / fix / fixoff md5 and strict verdict, the
# fix's firings (the .226 trace), MOVE when fix != law, OFF_OK when fixoff == law, and for a mover whether the
# uhdm-dumps (weaklyReferenced tail cut) of law and fix are identical (DUMP_SAME) or not (DUMP_DIFF).
# Fail-closed on $FENCED (env.sh, case.sh refuses a fenced path); four case dirs at a time (P).
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$FIX" ] && [ -x "$LAW" ] || { echo "lawfix.sh: LAW/FIX not executable" >&2; exit 2; }
O=$1; shift; D=$(cd "$(dirname "$0")" && pwd); : > $O
one() {
  c=$1
  for el in 0 1; do
    tr=$(mktemp -d /tmp/r11u226_lftr.XXXXXX)
    a=$(EL=$el bash $D/case.sh $c lw $LAW); b=$(EL=$el bash $D/case.sh $c fx $FIX R11V226_TRACE=$tr); z=$(EL=$el bash $D/case.sh $c fxoff $FIX R11V226_OFF=1)
    rel=$(echo "$a" | awk '{print $1}'); ma=$(echo "$a" | grep -o 'md5=\S*'); mb=$(echo "$b" | grep -o 'md5=\S*'); mz=$(echo "$z" | grep -o 'md5=\S*')
    sa=$(echo "$a" | grep -o 'strict=\S*\|SURELOG_FAIL\|SLANG_FAIL' | head -1); sb=$(echo "$b" | grep -o 'strict=\S*\|SURELOG_FAIL\|SLANG_FAIL' | head -1)
    ra=$(echo "$a" | grep -o 'rc=[0-9]*'); rb=$(echo "$b" | grep -o 'rc=[0-9]*')
    fired=$(cat $tr/*.226 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s,", $2, $1}'); rm -rf $tr
    mv="SAME"; dd="-"
    if [ "$ma" != "$mb" ]; then mv="MOVE"
      w=$GW/$rel
      if [ -f $w/lw.uhdm ] && [ -f $w/fx.uhdm ]; then
        x=$($UHDM_DUMP $w/lw.uhdm 2>/dev/null | tail -n +2 | sed '/^\\_weaklyReferenced:/,$d' | md5sum); y=$($UHDM_DUMP $w/fx.uhdm 2>/dev/null | tail -n +2 | sed '/^\\_weaklyReferenced:/,$d' | md5sum)
        [ "$x" = "$y" ] && dd=DUMP_SAME || dd=DUMP_DIFF
      fi
    fi
    ok=$([ "$ma" = "$mz" ] && echo OFF_OK || echo OFF_BAD)
    printf '%s\tlaw:%s %s %s\tfix:%s %s %s\t%s\t%s\t%s\tfired:%s\n' "$rel" "$sa" "$ra" "$ma" "$sb" "$rb" "$mb" "$mv" "$dd" "$ok" "${fired:--}"
  done
}
export -f one; export D LAW FIX GW UHDM_DUMP
printf '%s\n' "$@" | xargs -P ${P:-4} -I{} bash -c 'one {}' >> $O
