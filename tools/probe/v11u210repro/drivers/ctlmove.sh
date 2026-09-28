#!/bin/bash
# v11u210 (after r11u210 drivers/ctlmove.sh): wide byte-control mover scan (no golden): export every listed case dir
# with the pristine and the law binary (ELAB=1: --elabuhdm), print `<case> MOVED` for a database that differs,
# `<case> RC <pris rc> <law rc>` whenever either binary exits non-zero, `NODB` when neither writes one.
# usage: ctlmove.sh <list of case dirs relative to tools/probe>   (fence fail-closed; a fenced name is refused)
REPO=/home/heyfey/git-repos/slang-uhdm
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "ctlmove: fence unreadable" >&2; exit 3; }
T=/tmp/v11u210_ctl${ELAB:+_elab}; mkdir -p $T
one() { r=$1; c=$REPO/tools/probe/$r; for f in $FENCED; do grep -qw -- "$f" <<< "$c" && { echo "$r FENCED"; return; }; done
  k=$(echo "$c" | md5sum | cut -c1-10); o=$T/$k; mkdir -p $o; E=; [ -n "$ELAB" ] && E=--elabuhdm
  SRC=dut.sv; [ -f "$c/args" ] && SRC=$(cat "$c/args"); [ ! -f "$c/args" ] && [ -f "$c/files" ] && SRC=$(cat "$c/files" | tr "\n" " ")
  declare -A rc
  for b in pris law; do rm -f $o/$b.uhdm; ( cd $c && timeout 120 /tmp/v11u210_bin/$b.bin $SRC --single-unit --nobuiltin $E -o $o/$b.uhdm > /dev/null 2>&1 ); rc[$b]=$?; done
  [ "${rc[pris]}" != 0 ] || [ "${rc[law]}" != 0 ] && echo "$r RC ${rc[pris]} ${rc[law]}"
  if [ ! -s $o/pris.uhdm ] && [ ! -s $o/law.uhdm ]; then echo "$r NODB"; rm -rf $o; return; fi
  cmp -s $o/pris.uhdm $o/law.uhdm && rm -rf $o || echo "$r MOVED"; }
export -f one; export T REPO ELAB FENCED
xargs -P3 -I{} bash -c 'one {}' < $1 | sort
echo "LISTED $(wc -l < $1)"
