#!/bin/bash
# v11u215: wide byte control. usage: wide.sh <list> <tag>  (ELAB=1 for --elabuhdm). One line per dir:
# <dir> <rc pris> <rc law> MOVED|SAME|NODB ; keeps both databases of a mover under /tmp/v11u215_wide_<tag>/<key>/
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
T=/tmp/v11u215_wide_$2${ELAB:+_elab}; mkdir -p $T
one() { c=$1; for f in $FENCED; do grep -qw "$f" <<< "$c" && { echo "$c FENCED"; return; }; done
  k=$(echo "$c" | md5sum | cut -c1-12); o=$T/$k; mkdir -p $o; E=; [ -n "$ELAB" ] && E=--elabuhdm
  SRC=dut.sv; [ -f "$c/args" ] && SRC=$(cat "$c/args"); [ ! -f "$c/args" ] && [ -f "$c/files" ] && SRC=$(cat "$c/files" | tr "\n" " ")
  rcs=""
  for b in pris law; do rm -f $o/$b.uhdm; ( cd $c && timeout 300 $B/$b.bin $SRC --single-unit --nobuiltin $E -o $o/$b.uhdm > /dev/null 2>&1 ); rcs="$rcs $?"; done
  if [ ! -s $o/pris.uhdm ] && [ ! -s $o/law.uhdm ]; then echo "$c$rcs NODB"; rm -rf $o; return; fi
  if cmp -s $o/pris.uhdm $o/law.uhdm; then echo "$c$rcs SAME"; rm -rf $o; else echo "$c$rcs MOVED $k"; fi; }
export -f one; export T B ELAB FENCED
cat $1 | xargs -P3 -I{} bash -c 'one {}' | sort
