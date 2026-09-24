#!/bin/bash
# pinrow.sh <exporter -g1> <type e.g. logic_net> <name> <row workdir (verify_golden)> <test dir>
# ranks the objects of the row's database (objrank), then stops the -g1 exporter at that rank's mint.
bin=$1; ty=$2; nm=$3; rw=$4; td=$5
r=$(/tmp/r11u130_bin/objrank $rw/slang.uhdm | awk -F'\t' -v t=$ty -v n=$nm '$1==t && $4==n{print $2}' | head -1)
mk=Make$(echo ${ty:0:1} | tr a-z A-Z)${ty:1}
args=$(grep '^slang:' $rw/cmds.txt | sed 's/^slang: *//' | python3 -c "import sys,shlex; a=shlex.split(sys.stdin.read()); i=a.index('-o'); del a[i:i+2]; print(shlex.join(a[1:]))")
echo "rank=$r mk=$mk"
mkdir -p /tmp/r11u130_gdb; cd $td
eval "timeout 600 gdb -q -batch -ex 'set pagination off' -ex 'break UHDM::Serializer::$mk' -ex 'ignore 1 $((r-1))' -ex run -ex 'bt 12' -ex kill --args $bin $args -o /tmp/r11u130_gdb/pr_$$.uhdm" 2>&1 | grep -E '^#[0-9]+' | sed -E 's/ \(.*\) at / at /; s/^(#[0-9]+) +0x[0-9a-f]+ in /\1 /' | cut -c1-160
rm -f /tmp/r11u130_gdb/pr_$$.uhdm
