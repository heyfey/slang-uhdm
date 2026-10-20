#!/bin/bash
# r11u415 ddiff.sh <rowdir>: normalized dump diff golden vs ours (ids, files stripped)
d=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
k=$(echo $d | md5sum | cut -c1-8)
[ -f /tmp/r11u415_scr/g_$k.dump ] || $D $(/tmp/r11u415_drv/gold.sh $d) > /tmp/r11u415_scr/g_$k.dump 2>/dev/null
[ -f /tmp/r11u415_scr/s_$k.dump ] || $D $d/slang.uhdm > /tmp/r11u415_scr/s_$k.dump 2>/dev/null
n(){ sed 's/, id:[0-9]*//; s/ \[[0-9]*\]//; s/file:[^,]*, //' $1 | grep -v 'vpiFile\|Restored design\|^design'; }
diff <(n /tmp/r11u415_scr/g_$k.dump) <(n /tmp/r11u415_scr/s_$k.dump)
