#!/usr/bin/env bash
source /tmp/v11u140_scratch/env.sh
c=$(realpath ${1%/})
g=/tmp/v11u140_gcache/$(md5sum $c/dut.sv|cut -c1-16).uhdm
t=/tmp/v11u140_scratch/dd3_$$; mkdir -p $t
norm() { $UHDM_DUMP "$1" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g' | sed "s#$c##g; s#/tmp/v11u140_gcache##g" | tail -n +2; }
norm $g > $t/g
r=""
for b in pris law ver1; do r="$r $b=$(diff $t/g <(norm $c/$b.uhdm) | grep -c '^[<>]')"; done
rm -rf $t
echo "$(basename $(dirname $c))/$(basename $c)$r"
