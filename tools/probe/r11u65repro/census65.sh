#!/usr/bin/env bash
# r11u65 CENSUS DRIVER.
#
#   census65.sh shape  <workdir>   GOLDEN-vs-GOLDEN SHAPE CENSUS, aggregated
#       over every arm's own golden database (read out of its cmds.txt): which
#       (view x scope kind x net kind x typespec kind x element ts kind x
#       named?) cells carry which vpiNetType values, and how often.  This is
#       the calibration the ours-vs-golden join is read against.
#   census65.sh join   <workdir>   OURS-vs-GOLDEN join per arm, on
#       (view, scope path, net name, net kind), printing every NT-DIFF BY NAME.
#
# Reads databases only; runs no binary.
set -u
MODE=${1:?shape|join}
WD=${2:?workdir}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for f in "$WD"/*/*/cmds.txt; do
  [ -f "$f" ] || continue
  d=$(dirname "$f")
  key="$(basename "$(dirname "$d")")/$(basename "$d")"
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$f" | head -1)
  [ -n "$g" ] || continue
  gdb=$(ls "$g"/*.uhdm 2>/dev/null | head -1)
  [ -n "$gdb" ] || continue
  case "$MODE" in
    shape) "$HERE/netcen65" --shape --tag="$key" "$gdb" 2>/dev/null | grep '^SHAPE ' ;;
    join)  [ -f "$d/slang.uhdm" ] || continue
           "$HERE/netcen65" --join --tag="$key" "$gdb" "$d/slang.uhdm" 2>/dev/null ;;
  esac
done
