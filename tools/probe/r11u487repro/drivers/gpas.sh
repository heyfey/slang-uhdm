#!/bin/bash
# gpas.sh <casedir> [tag]: the elaborated param_assigns of golden (or of <tag>)
source $(dirname "$0")/env.sh || exit 1
W=/tmp/r11u487_runs$(realpath $1); F=$W/sl/slpp_all/surelog.uhdm; [ -n "$2" ] && F=$W/$2.uhdm
$UHDM_DUMP $F 2>/dev/null | sed 's#file:[^,]*,#file:,#g' > /tmp/r11u487_gd_$$.txt
python3 $(dirname "$0")/pas.py /tmp/r11u487_gd_$$.txt; rm -f /tmp/r11u487_gd_$$.txt
