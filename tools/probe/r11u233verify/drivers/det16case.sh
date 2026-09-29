#!/bin/bash
# r11u233: det16case.sh <binary> <tag> <draws> <casedir>...: <draws> concurrent parse-view runs of the binary per case
# (the probe harness's arguments dut.sv --single-unit --nobuiltin, R11U228_TRACE on the first draw only as the firing
# control), prints the md5 histogram and exit codes per case.  Fail-closed on $FENCED.
source "$(dirname "$0")/env.sh" || exit 2
B=$1; TAG=$2; N=$3; shift 3; [ -x "$B" ] || { echo "det16case.sh: $B not executable" >&2; exit 2; }
O=/tmp/r11u233_det16/$TAG; rm -rf $O; mkdir -p $O
for c in "$@"; do
  c=$(realpath $c); for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "fenced refused"; continue 2; }; done
  k=$(echo $c | md5sum | cut -c1-8); mkdir -p $O/$k/tr
  for i in $(seq 1 $N); do ( cd $c && if [ $i = 1 ]; then R11U228_TRACE=$O/$k/tr timeout 300 "$B" dut.sv --single-unit --nobuiltin -o $O/$k/$i.uhdm > /dev/null 2>&1; else timeout 300 "$B" dut.sv --single-unit --nobuiltin -o $O/$k/$i.uhdm > /dev/null 2>&1; fi; echo $? > $O/$k/$i.rc ) & done; wait
  echo "$TAG $(echo $c | sed 's#.*/tools/probe/##') fired=[$(cat $O/$k/tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort | uniq -c | tr -s ' ' | tr '\n' ' ')] md5s: $(md5sum $O/$k/*.uhdm | cut -c1-12 | sort | uniq -c | tr -s ' ' | tr '\n' ' ') rc: $(cat $O/$k/*.rc | sort | uniq -c | tr -s ' ' | tr '\n' ' ')"
done
