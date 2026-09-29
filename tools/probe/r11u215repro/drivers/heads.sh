#!/bin/bash
# heads.sh <sweep surelog workdir> <max> rows...   (fence: rows given explicitly; refuses fenced)
WD=$1; MX=$2; shift 2
FENCED="$(grep -m1 '^FENCED=' /home/heyfey/git-repos/slang-uhdm/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo fence; exit 3; }
for r in "$@"; do for f in $FENCED; do [ "$r" = "$f" ] && { echo refused; exit 3; }; done
 for m in default testflags; do d=$(ls -d $WD/$m/$r-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | cut -d' ' -f4)/golden.uhdm; [ -f $d/slang.uhdm ] || continue
  echo "== $r $m"; timeout 900 /tmp/r11u215_bin/uhdm-strictcmp --max $MX $g $d/slang.uhdm 2>&1 | grep -E '^#|raw|^  [AB]:|STRICT|fields' | head -$((MX*4+4)); done; done
