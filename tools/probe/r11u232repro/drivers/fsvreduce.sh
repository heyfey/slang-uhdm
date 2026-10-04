#!/bin/bash
# (r11u232) fsvreduce.sh <file.sv> <scratch>: the § ovrMemberReadLocatesLeftover232 decode probe on a reduced copy of
# FuncStructVal (not fenced; refused if the path names a fenced test): runs the pinned Surelog with check_probe's
# arguments and counts the constants located on the line of the `.INPUT_WIDTH(` override.
[ "$(echo ${FENCED:-} | wc -w)" = 4 ] || { echo "fsvreduce.sh: source drivers/env.sh" >&2; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo "fence" >&2; exit 2; }; done
[ -x "$SURELOG" ] && [ -x "$OBJID" ] || { echo "fsvreduce.sh: SURELOG / OBJID" >&2; exit 2; }
f=$(realpath $1); d=$(mktemp -d $2/run.XXXX); cp $f $d/dut.sv
ln=$(grep -n 'INPUT_WIDTH(' $d/dut.sv | head -1 | cut -d: -f1)
(cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $d/o > $d/sl.log 2>&1)
g=$(find $d/o -name '*.uhdm' | head -1); [ -n "$g" ] || { echo "NOUHDM"; rm -rf $d; exit 1; }
$OBJID $g > $d/ids
echo "located=$(grep -P "\tconstant\t.*\t$ln:[0-9]+-$ln:[0-9]+\t" $d/ids | wc -l) line=$ln"
rm -rf $d
