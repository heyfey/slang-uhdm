#!/usr/bin/env bash
# r11u25 — SHAPE LISTER golden-vs-ours for one sweep workdir entry.
# usage: cellcmp25.sh <workdir-entry>        (the dir holding cmds.txt+slang.uhdm)
set -u
D=${1:?dir}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
C=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/carhs25.py
g=$(sed -n 's/.*golden cache hit \(\S*\))/\1/p' $D/cmds.txt)
if [ -z "$g" ]; then echo "NO CACHE LINE in $D/cmds.txt"; exit 1; fi
$DUMP $g/golden.uhdm > /tmp/r11u25_scr/.g.dump 2>/dev/null
$DUMP $D/slang.uhdm  > /tmp/r11u25_scr/.o.dump 2>/dev/null
python3 $C /tmp/r11u25_scr/.g.dump | sort > /tmp/r11u25_scr/.g.cells
python3 $C /tmp/r11u25_scr/.o.dump | sort > /tmp/r11u25_scr/.o.cells
echo "### $D  golden=$(wc -l < /tmp/r11u25_scr/.g.cells) ours=$(wc -l < /tmp/r11u25_scr/.o.cells)"
diff /tmp/r11u25_scr/.g.cells /tmp/r11u25_scr/.o.cells
