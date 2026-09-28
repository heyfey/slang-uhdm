#!/bin/bash
# r11u196: byte composition matrix.  For every case dir under the given grid dirs, export with each binary x switch
# state and print one md5 per state:  <case> <state>=<md5[:8]> ...   (default view; EL=1 adds --elabuhdm)
# usage: compose.sh "<bin>[:<ENV=1>[,<ENV=1>]]" ... -- <grid dir>...   (fence: refuses fenced paths)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
states=(); while [ "$1" != "--" ]; do states+=("$1"); shift; done; shift
ox=""; [ "${EL:-0}" = 1 ] && ox="--elabuhdm"
T=/tmp/r11u196_compose; mkdir -p $T
for g in "$@"; do g=$(cd "$g" && pwd); for c in $(find "$g" -name 'dut.sv' -o -name args -o -name files | xargs -n1 dirname | sort -u); do
  r196_fenced "$c" && continue
  SRC=dut.sv; [ ! -f "$c/dut.sv" ] && [ -f "$c/dut.v" ] && SRC=dut.v
  [ -f "$c/args" ] && SRC=$(cat "$c/args"); [ ! -f "$c/args" ] && [ -f "$c/files" ] && SRC=$(tr "\n" " " < "$c/files")
  line="${c#$R196_REPO/tools/probe/}"
  for st in "${states[@]}"; do b=${st%%:*}; e=""; [ "$st" != "$b" ] && e=$(echo ${st#*:} | tr ',' ' ')
    rm -f $T/o.uhdm; ( cd "$c" && env $e $R196_BIN/$b $SRC --single-unit --nobuiltin $ox -o $T/o.uhdm > /dev/null 2>&1 ); rc=$?
    h=$(md5sum < $T/o.uhdm 2>/dev/null | cut -c1-8); line="$line $st=${h:-none}/$rc"; done
  echo "$line"; done; done
