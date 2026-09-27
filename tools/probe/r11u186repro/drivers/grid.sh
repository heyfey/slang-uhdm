#!/bin/bash
# r11u186: judge case dirs with frozen binaries exactly as check_probe.py does (case.sh); one line per case:
# <case> <verdict per binary>.  usage: grid.sh <out tag> <case dir>... ; GRIDBINS (names under /tmp/r11u186_bin)
# default "pris.bin law.bin".  Each case's artifacts land in /tmp/r11u186_grid/<tag>/<bin>/<case path>.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
TAG=$1; shift
one() { c=$1; r=$(echo "$c" | sed 's#.*/tools/probe/##'); line="$r"
  for b in ${GRIDBINS:-pris.bin law.bin}; do
    O=/tmp/r11u186_grid/$TAG/$b/$r
    out=$(SLANG_UHDM=/tmp/r11u186_bin/$b bash $HERE/case.sh $c $O 2>/dev/null)
    case "$out" in
      SLANG_FAIL*|SURELOG_FAIL*) v=${out%% *};;
      *) st=$(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt | cut -d' ' -f1)
         n=$(grep -o 'objects_differing=[0-9]*' $O/strict.txt 2>/dev/null | cut -d= -f2)
         crc=$(echo "$out" | sed 's/^cmp=\([0-9]*\).*/\1/')
         if [ "$st" = STRICT_EQUAL ] && [ "$crc" = 0 ]; then v=EQUAL
         elif [ "$st" = STRICT_NOTEQUAL ]; then v="STRICT_NOTEQUAL:$(grep -m1 '^STRICT_NOTEQUAL' $O/strict.txt | cut -d' ' -f2)($n)"
         else v="NOT_EQUAL(cmp=$crc)"; fi;;
    esac
    [ -f $O/ours.uhdm ] && v="$v#$(md5sum < $O/ours.uhdm | cut -c1-8)"
    line="$line	$v"; done; echo "$line"; }
export -f one; export HERE TAG GRIDBINS
for d in "$@"; do find $(cd $d && pwd) -name dut.sv -printf '%h\n'; done | sort -u | xargs -P3 -I{} bash -c 'one {}' | sort
