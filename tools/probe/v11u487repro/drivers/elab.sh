#!/bin/bash
# elab.sh <casedir> [tag]: elab.py over golden (or <tag>)
source $(dirname "$0")/env.sh || exit 1
W=/tmp/v11u487_runs$(realpath $1); F=$W/sl/slpp_all/surelog.uhdm; [ -n "$2" ] && F=$W/$2.uhdm
$UHDM_DUMP $F 2>/dev/null | sed 's#file:[^,]*,#file:,#g' > /tmp/v11u487_ed_$$.txt
python3 $(dirname "$0")/elab.py /tmp/v11u487_ed_$$.txt; rm -f /tmp/v11u487_ed_$$.txt
