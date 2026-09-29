#!/bin/bash
# r11u215: crash parity over a case list: every case dir exported with the pristine and the law binary (ELAB=1:
# --elabuhdm), the exit codes recorded; prints `<case> <rc pristine> <rc law>` for every case where either rc is
# >= 128 (a signal) or the two differ.  Fence fail-closed (env.sh).   usage: crashparity.sh <list> <law bin>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
T=/tmp/r11u215_crash${ELAB:+_elab}; mkdir -p $T
one() { c=$1; for f in $FENCED; do grep -qw "$f" <<< "$c" && { echo "$c FENCED"; return; }; done
  k=$(echo "$c" | md5sum | cut -c1-10); o=$T/$k; mkdir -p $o; E=; [ -n "$ELAB" ] && E=--elabuhdm
  SRC=dut.sv; [ -f "$c/args" ] && SRC=$(cat "$c/args"); [ ! -f "$c/args" ] && [ -f "$c/files" ] && SRC=$(cat "$c/files" | tr "\n" " ")
  r=(); for b in pris.bin $LB; do rm -f $o/$b.uhdm; ( cd $c && $B/$b $SRC --single-unit --nobuiltin $E -o $o/$b.uhdm > /dev/null 2>&1 ); r+=($?); done
  if [ "${r[0]}" != "${r[1]}" ] || [ "${r[0]}" -ge 128 ] || [ "${r[1]}" -ge 128 ]; then echo "$c ${r[0]} ${r[1]}"; fi; }
export -f one; export T B LB=$2 ELAB FENCED
cat $1 | xargs -P3 -I{} bash -c 'one {}' 2>/dev/null | sort
echo "LISTED $(wc -l < $1)"
