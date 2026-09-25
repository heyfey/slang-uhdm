#!/bin/bash
# rowdump.sh <workdir> <corpus> <mode> <name> <outdir>: the strict record dumps (A = golden, B = ours)
# of one row of a verify_golden workdir.  Fail-closed on $FENCED (four names, never spelled here).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rowdump.sh: export FENCED (four names) first" >&2; exit 1; }
WD=$1; C=$2; M=$3; n=$4; O=$5
for f in $FENCED; do [ "$f" = "$n" ] && { echo "fenced: skipped"; exit 0; }; done
SC=${STRICT_CMP:-/tmp/r11u158_bin/uhdm-strictcmp}
d=$(ls -d $WD/$C/$M/$n-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no dir"; exit 1; }
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
[ -f "$g" ] || g=$(ls $d/*.uhdm | grep -v slang.uhdm | head -1)
mkdir -p $O; $SC --max ${MAX:-50} --dump-a $O/$n.$M.a.txt --dump-b $O/$n.$M.b.txt $g $d/slang.uhdm > $O/$n.$M.strict 2>&1
echo "$g" > $O/$n.$M.golden_path; tail -1 $O/$n.$M.strict
