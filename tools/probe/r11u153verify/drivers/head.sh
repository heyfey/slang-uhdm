#!/bin/bash
# head.sh <workdir> <corpus> <mode> <name> [max]: the first strict records (golden vs ours) of one corpus row-mode
# of a sweep workdir. Fail-closed: refuses without $FENCED (the four slang-fenced names) and skips those names.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "head.sh: export FENCED (four names) first" >&2; exit 1; }
W=$1; c=$2; m=$3; n=$4; mx=${5:-1}
for f in $FENCED; do [ "$f" = "$n" ] && { echo "$n FENCED-SKIP"; exit 0; }; done
d=$(ls -d $W/$c/$m/$n-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "$n/$m NODIR"; exit 0; }
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
[ -f "$g" ] || g=$(grep -o '/home/[^ ]*slang-uhdm-goldens/[0-9a-f]*' $d/cmds.txt | head -1)/golden.uhdm
timeout 600 ${STRICT_CMP:-/tmp/r11u153_bin/uhdm-strictcmp} --max $mx $g $d/slang.uhdm 2>&1 | grep -A2 '^#' | head -$((3*mx)) | sed "s#^#$n/$m #"
