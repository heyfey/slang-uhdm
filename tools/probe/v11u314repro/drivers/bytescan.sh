#!/bin/bash
# v11u314 bytescan.sh <dirlist> <out>: pristine vs law database bytes in both views for each case dir of the list
# (one dut.sv dir per line, the list already built and filtered by $FENCED; refused again here per dir).
# One line per case-view: <dir> <view> rcP rcL SAME|MOVE.  Needs $P $L (frozen binaries) and $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytescan: FENCED unset" >&2; exit 2; }
[ -x "$P" ] && [ -x "$L" ] || { echo "bytescan: P/L not executable" >&2; exit 2; }
export FENCED P L; T=/tmp/v11u314_bs; mkdir -p $T; export T
one() { case "$1" in /*) ;; *) echo "$1 NOTABS"; return;; esac; d=$(dirname "$1"); for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "$d REFUSED"; return; }; done
  for v in d e; do ex=""; [ $v = e ] && ex="--elabuhdm"; k=$T/$(echo "$d$v" | md5sum | cut -c1-16)
    rm -f $k.p $k.l
    (cd "$d" && timeout 120 $P dut.sv --single-unit --nobuiltin $ex -o $k.p >/dev/null 2>&1 </dev/null); a=$?
    (cd "$d" && timeout 120 $L dut.sv --single-unit --nobuiltin $ex -o $k.l >/dev/null 2>&1 </dev/null); b=$?
    if cmp -s $k.p $k.l; then s=SAME; else s=MOVE; fi; echo "$d $v $a $b $s"; rm -f $k.p $k.l; done; }
export -f one
tr '\n' '\0' < "$1" | xargs -0 -P ${GP:-3} -I{} bash -c 'one "{}"' > "$2"
