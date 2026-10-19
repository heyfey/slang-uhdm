# ddiff.sh golden ours : normalized dump diff
. /tmp/r11u403_scr/env.sh
diff <($UHDM_DUMP $1 2>&1 | sed -e 's/id:[0-9]*//' -e 's#file:[^,]*/#file:#' -e 1d) <($UHDM_DUMP $2 2>&1 | sed -e 's/id:[0-9]*//' -e 's#file:[^,]*/#file:#' -e 1d)
