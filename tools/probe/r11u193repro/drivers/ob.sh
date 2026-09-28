#!/bin/bash
# r11u193: order-blind uhdm-dump difference of one row-mode between two sweep workdirs (paths normalised, sorted,
# comm -3 line count).  usage: ob.sh <wdA> <wdB> <corpus> <mode> <row>   (refuses fenced rows)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
A=$1; B=$2; C=$3; M=$4; R=$5; r193_fenced "$R" && { echo "ob.sh: fenced row refused"; exit 3; }
da=$(ls -d $A/$C/$M/$R-* | head -1); db=$(ls -d $B/$C/$M/$R-* | head -1)
$UHDM_DUMP $da/slang.uhdm 2>/dev/null | sed "s#$A##g" | sort > /tmp/r11u193_ob_a.txt
$UHDM_DUMP $db/slang.uhdm 2>/dev/null | sed "s#$B##g" | sort > /tmp/r11u193_ob_b.txt
echo "$C/$M/$R orderblind_lines=$(comm -3 /tmp/r11u193_ob_a.txt /tmp/r11u193_ob_b.txt | wc -l)"
