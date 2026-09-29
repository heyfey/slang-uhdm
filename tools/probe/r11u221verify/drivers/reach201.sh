#!/bin/bash
# (r11u217) reach201.sh <list of case dirs>: § landingSwitchReach210's claim on fresh cases: per case-view, the bytes of
# law.bin with R11U210_LANDING201_OFF against the bytes with the full list of landing 201's old switches
# (R11U201_OFF R11V201_OFF R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF R11U210_GENBITS201_OFF),
# and each against the switch-free bytes.  Fail-closed on $FENCED (drivers/env.sh).
source "$(dirname "$0")/env.sh" || exit 2
T=/tmp/r11u221_reach; mkdir -p $T
one() {
  c=$1; for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "FENCED $c"; return; }; done
  k=$(echo $c | md5sum | cut -c1-10); SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  for el in "" --elabuhdm; do
    for s in free new old; do
      case $s in free) E=;; new) E="R11U210_LANDING201_OFF=1";; old) E="R11U201_OFF=1 R11V201_OFF=1 R11U200_NEWARRHP_OFF=1 R11U200_UNITFOLD_OFF=1 R11U200_FOLDDEPTH_OFF=1 R11U210_GENBITS201_OFF=1";; esac
      rm -f $T/$k$el.$s.uhdm; (cd $c && env $E timeout 300 $LAW $SRC --single-unit --nobuiltin $el -o $T/$k$el.$s.uhdm > /dev/null 2>&1)
    done
    m() { md5sum < $T/$k$el.$1.uhdm 2>/dev/null | cut -c1-10; }
    echo "${c##*/tools/probe/}${el:+ el} new=old:$([ "$(m new)" = "$(m old)" ] && echo Y || echo N) new=free:$([ "$(m new)" = "$(m free)" ] && echo Y || echo N)"
    rm -f $T/$k$el.*.uhdm
  done
}
export -f one; export T LAW FENCED
xargs -P3 -I{} bash -c 'one {}' < $1
