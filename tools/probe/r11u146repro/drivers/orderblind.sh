#!/bin/bash
# orderblind.sh <corpus> <mode> <name>: order-blind uhdm-dump diff, pristine vs law vs law-under-R11U146_CLSTDPKG_OFF
# (the UVM coin rows: attribute by sorted, path-normalised dumps).  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 1
c=$1; m=$2; n=$3; for f in $FENCED; do [ "$f" = "$n" ] && exit 0; done
D=${UHDM_DUMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
S=/tmp/r11u146_attrib/$c/$m/$(basename $(ls -d /tmp/r11u146_swL/$c/$m/$n-*))
norm() { $D $1 2>/dev/null | sed -E 's#/tmp/r11u146_sw[PL]/[^ ,]*##g; s#/tmp/r11u146_attrib/[^ ,]*##g; s#, id:[0-9]+##g' | sort; }
norm /tmp/r11u146_swP/$c/$m/$n-*/slang.uhdm > /tmp/r11u146_ob_P.txt
norm /tmp/r11u146_swL/$c/$m/$n-*/slang.uhdm > /tmp/r11u146_ob_L.txt
norm $S/S.uhdm > /dev/null 2>&1
echo "$n/$m pristine-vs-law: $(diff /tmp/r11u146_ob_P.txt /tmp/r11u146_ob_L.txt | grep -c '^[<>]') lines; law lines naming uvm_pkg:: under a class typedef member: $(diff /tmp/r11u146_ob_P.txt /tmp/r11u146_ob_L.txt | grep '^>' | grep -c 'uvm_pkg::')"
