#!/usr/bin/env bash
# r11u53 SHAPE LISTER — the census's positive control, run beside it.
#
# A census that counts `$bits` fold sites can read ZERO because the construct
# is absent OR because the counter never reached the database.  This lister
# prints, per VIEW, the SHAPES both sides actually carry at the sites the law
# touches, so a zero is always accompanied by the shape inventory that
# produced it:
#   Kg / Kours  — `sys_func_call: ($bits)` objects (the KEEP shape)
#   TPg / TPours— `type_parameter:` objects (the construct is present at all)
# A row with TP=0 on BOTH sides is a row the law cannot reach and is reported
# as OUT-OF-REACH, never as agreement.
#
#   usage: shape53.sh <rowdir> [<rowdir> ...]
# where <rowdir> is a verify_golden.py per-test workdir (it holds cmds.txt and
# slang.uhdm).
set -u
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
printf "%-44s %-6s %5s %5s %5s %5s  %s\n" ROW VIEW Kg Kours TPg TPours VERDICT
for D in "$@"; do
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)/golden.uhdm
  S=$D/slang.uhdm
  if [ ! -f "$G" ] || [ ! -f "$S" ]; then
    printf "%-44s %-6s %5s %5s %5s %5s  %s\n" "$(basename $D)" - - - - - NO-DATABASE
    continue
  fi
  $DUMP "$G" 2>/dev/null > /tmp/.sh53.g.$$
  $DUMP "$S" 2>/dev/null > /tmp/.sh53.o.$$
  for v in DEF ELAB; do
    if [ $v = DEF ]; then rng='/uhdmall(Modules|Packages|Classes):/{f=1} /uhdmtop(Modules|Packages):/{f=0} f'
    else                  rng='/uhdmtop(Modules|Packages):/{f=1} /weaklyReferenced:/{f=0} f'; fi
    kg=$(awk "$rng" /tmp/.sh53.g.$$ | grep -c 'sys_func_call: (\$bits)'; true)
    ko=$(awk "$rng" /tmp/.sh53.o.$$ | grep -c 'sys_func_call: (\$bits)'; true)
    tg=$(awk "$rng" /tmp/.sh53.g.$$ | grep -c 'type_parameter:'; true)
    to=$(awk "$rng" /tmp/.sh53.o.$$ | grep -c 'type_parameter:'; true)
    vd=OK; [ "$tg" = 0 ] && [ "$to" = 0 ] && vd=OUT-OF-REACH
    [ "$vd" = OK ] && [ "$kg" != "$ko" ] && vd="KEEP-COUNT-DIFFERS"
    printf "%-44s %-6s %5s %5s %5s %5s  %s\n" "$(basename $D)" $v $kg $ko $tg $to $vd
  done
  rm -f /tmp/.sh53.g.$$ /tmp/.sh53.o.$$
done
