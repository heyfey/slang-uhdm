#!/bin/bash
# cx.sh <case dir> [bin] [max] [k]: differing strict records with ancestors
source /tmp/r11u145_env.sh
d=$(cd "$1" && pwd); b=${2:-/tmp/r11u145_bin/pristine}
/tmp/r11u145_s/rc.sh $d $b > /dev/null
g=/tmp/r11u145_s/gold/$(echo $d | md5sum | cut -c1-12)/g.uhdm
o=/tmp/r11u145_s/ours/$(echo $d$b | md5sum | cut -c1-12).uhdm
/tmp/r11u145_s/ctx2.sh $g $o ${3:-6} ${4:-0}
