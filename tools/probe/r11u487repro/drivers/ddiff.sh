#!/bin/bash
# ddiff.sh <casedir> <tag>: path-normalised dump diff golden vs <tag>
source $(dirname "$0")/env.sh || exit 1
W=/tmp/r11u487_runs$(realpath $1)
diff <($UHDM_DUMP $W/sl/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g') <($UHDM_DUMP $W/$2.uhdm 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g')
