#!/bin/bash
# v11u210 (after r11u210 drivers/awaycorp.sh): order-blind AWAY-moved-record census of corpus movers (map 12's method,
# v11u202's away.py) in strict-record space AND in uhdm-dump-line space (dumpaway.py, names inside typespec copies
# included). CONTROL=1 swaps the pristine and law databases (the positive control: LOST must then equal GAINED).
# usage: awaycorp.sh <pristine sweep wd> <law sweep wd> <mover list> <outdir>   (fence fail-closed)
HERE=$(cd "$(dirname "$0")" && pwd); REPO=/home/heyfey/git-repos/slang-uhdm
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "awaycorp: fence unreadable" >&2; exit 3; }
P=$1; L=$2; M=$3; O=$4; mkdir -p $O; [ -n "${CONTROL:-}" ] && { t=$P; P=$L; L=$t; }
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
while read -r p; do
  t0=$(basename $p | sed 's/-[0-9a-f]*$//'); for f in $FENCED; do [ "$t0" = "$f" ] && { echo "$p FENCED refused"; continue 2; }; done
  g=$(grep -o 'golden cache [a-z]* [^)]*' $P/$p/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
  t=$O/$(echo $p | tr '/' '_'); mkdir -p $t
  SCMP=/tmp/v11u210_bin/uhdm-strictcmp python3 $HERE/away.py $gu $P/$p/slang.uhdm $L/$p/slang.uhdm $t v > $t/away.txt
  $DUMP $gu 2>/dev/null > $t/g.dump; $DUMP $P/$p/slang.uhdm 2>/dev/null | sed 1d > $t/p.dump; $DUMP $L/$p/slang.uhdm 2>/dev/null | sed 1d > $t/l.dump
  python3 $HERE/dumpaway.py $t/g.dump $t/p.dump $t/l.dump > $t/dumpaway.txt; rm -f $t/*.dump $t/*.fa $t/*.fb
  echo "$p strict: $(head -1 $t/away.txt) | dump: $(head -1 $t/dumpaway.txt)"
done < $M
