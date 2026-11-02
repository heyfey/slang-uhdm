#!/bin/bash
# ddist.sh <golden> <ours>: path-normalized uhdm-dump diff line count (ids stripped)
source /tmp/r11u467_env.sh; [ -x "$UHDM_DUMP" ] || exit 1
n(){ "$UHDM_DUMP" "$1" 2>/dev/null | sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#/tmp[^ ,]*/##g'; }
diff <(n "$1") <(n "$2") | grep -c '^[<>]'
