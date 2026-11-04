#!/bin/bash
# ddiff.sh <casedir> <tag>: path-normalised dump diff golden vs <tag> for one case
source $(dirname "$0")/env.sh || exit 1
c=$(realpath "$1"); W=/tmp/r11u489_runs$c
d(){ $UHDM_DUMP "$1" 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g'; }
diff <(d $W/sl/slpp_all/surelog.uhdm) <(d $W/$2.uhdm)
