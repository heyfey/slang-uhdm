#!/bin/bash
# ob115.sh <lawRoot> <prisRoot> <rel>...: order-blind, path-normalised uhdm-dump diff of each
# named database (relative path under both sweep roots): line count + the first lines.
A=${1:?law}; B=${2:?pris}; shift 2
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for r in "$@"; do
  da=$(dirname "$A/$r"); db=$(dirname "$B/$r")
  diff <(timeout 1200 $DUMP "$A/$r" 2>&1 | tail -n +2 | sed "s#$da##g" | sort) <(timeout 1200 $DUMP "$B/$r" 2>&1 | tail -n +2 | sed "s#$db##g" | sort) > /tmp/r11u115_ob.txt
  echo "$r orderblind_lines=$(grep -c '^[<>]' /tmp/r11u115_ob.txt; true)"
  grep '^[<>]' /tmp/r11u115_ob.txt | head -${OBHEAD:-6} | cut -c1-160 | sed 's/^/    /'
done
