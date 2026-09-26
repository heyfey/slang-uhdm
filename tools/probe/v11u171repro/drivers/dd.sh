#!/bin/bash
# dd.sh <caseout-name> : uhdm-dump diff pris vs law (+golden option)
source /tmp/v11u171_scr/env.sh
O=/tmp/v11u171_caseout
$UHDM_DUMP $O/$1.pris/ours.uhdm 2>&1 | sed "s#$O/[^ ]*##g" > /tmp/v11u171_scr/$1.p.d
$UHDM_DUMP $O/$1.law/ours.uhdm 2>&1 | sed "s#$O/[^ ]*##g" > /tmp/v11u171_scr/$1.l.d
diff /tmp/v11u171_scr/$1.p.d /tmp/v11u171_scr/$1.l.d | head -${N:-40}
