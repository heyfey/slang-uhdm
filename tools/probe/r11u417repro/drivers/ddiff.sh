#!/bin/bash
# r11u417 ddiff.sh <rowdir>: normalized dump diff golden vs ours (ids, files stripped)
d=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
k=$(echo $d | md5sum | cut -c1-8)
[ -s /tmp/r11u417_scr/g_$k.dump ] || timeout 600 $D $($(dirname $0)/gold.sh $d) > /tmp/r11u417_scr/g_$k.dump 2>/dev/null
[ -s /tmp/r11u417_scr/s_$k.dump ] || timeout 600 $D $d/slang.uhdm > /tmp/r11u417_scr/s_$k.dump 2>/dev/null
n(){ sed 's/, id:[0-9]*//; s/ \[[0-9]*\]//; s/file:[^,]*, //' $1 | grep -v 'vpiFile\|Restored design\|^design'; }
diff <(n /tmp/r11u417_scr/g_$k.dump) <(n /tmp/r11u417_scr/s_$k.dump)
