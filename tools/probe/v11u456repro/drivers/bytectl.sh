#!/bin/bash
# bytectl.sh <binA> <binB> <casedir>...: runs both binaries on each case dir
# (files.lst if present, else dut.sv) and prints exit codes and SAME/MOVED.
# Explicit case DIRECTORIES only; outputs under /tmp/v11u456_ctl/<path>/.
A=$1; B=$2; shift 2
[ -x "$A" ] && [ -x "$B" ] || { echo "no binary"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c"); W=/tmp/v11u456_ctl$c; mkdir -p "$W"
  if [ -f "$c/files.lst" ]; then F=$(cat "$c/files.lst"); else F=dut.sv; fi
  rm -f "$W/a.uhdm" "$W/b.uhdm"
  (cd "$c" && "$A" $F -o "$W/a.uhdm" > "$W/a.log" 2>&1 </dev/null); ra=$?
  (cd "$c" && "$B" $F -o "$W/b.uhdm" > "$W/b.log" 2>&1 </dev/null); rb=$?
  if cmp -s "$W/a.uhdm" "$W/b.uhdm"; then s=SAME; else s=MOVED; fi
  echo "${c#*/tools/probe/} rcA=$ra rcB=$rb $s"
done
