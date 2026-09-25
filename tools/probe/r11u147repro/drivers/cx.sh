#!/bin/bash
# cx.sh <case dir> [bin] [max] [k]
d=$(cd "$1" && pwd); b=${2:-/tmp/r11u147_bin/pristine}
$(dirname $0)/rc.sh $d $b > /dev/null
g=$(cat /tmp/r11u147_s/gpath/$(echo $d | md5sum | cut -c1-12)); o=/tmp/r11u147_s/ours/$(echo $d$b | md5sum | cut -c1-12).uhdm
$(dirname $0)/ctx.sh $g $o ${3:-6} ${4:-0}
