#!/bin/bash
# incinfo.sh <a.uhdm> <b.uhdm>  — the include_file_info records of two databases side by side:
#   index, line(a), line(b), delta(b-a), included file basename (a).  Refuses a path naming a fenced test.
set -u
: "${FENCED:?}" "${UHDM_DUMP:?}"
for f in $FENCED; do echo "$1 $2" | grep -qw "$f" && { echo REFUSE; exit 3; }; done
ex() { "$UHDM_DUMP" "$1" 2>/dev/null | awk '/^\\_include_file_info:/{match($0,/line:[0-9]+/); l=substr($0,RSTART+5,RLENGTH-5)} /vpiIncludedFile:/{n=split($0,p,"/"); print l"\t"p[n]}'; }
paste <(ex "$1") <(ex "$2") | awk -F'\t' '{printf "%d\t%s\t%s\t%d\t%s\n", NR, $1, $3, $3-$1, $2}'
