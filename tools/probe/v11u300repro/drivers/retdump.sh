#!/bin/bash
# v11u300 retdump.sh <case dir> <d|e> [binary]: the elaborated package listing's (uhdmtopPackages) dump of the
# golden (no binary) or of the binary's database; fail-closed on $FENCED and on an unset $UHDM_DUMP.
H=$(cd "$(dirname "$0")" && pwd); source $H/env.sh || exit 2
[ -x "$UHDM_DUMP" ] || { echo "UHDM_DUMP unset" >&2; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo "fenced path refused" >&2; exit 2; }; done
if [ -n "$3" ]; then o=/tmp/v11u300_caseout/rd.$$.uhdm; rm -f $o; KEEP=$o bash $H/case.sh $1 $3 $2 >/dev/null; db=$o; else db=$(bash $H/gpath.sh $1 $2); fi
$UHDM_DUMP $db 2>/dev/null | awk '/^\|uhdmtopPackages/{p=1;next} /^\|uhdm/{p=0} p'
[ -n "$3" ] && rm -f $o
