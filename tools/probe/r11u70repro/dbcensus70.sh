#!/usr/bin/env bash
# r11u70 DB-SIDE CENSUS + POSITIVE CONTROL.  Runs the SHAPE LISTER over every
# database in a verify_golden workdir and counts the two columns the law moves:
#   OP67  param_assign cells whose Rhs is vpiCastOp over vpiConcatOp
#   OP75  param_assign cells whose Rhs is a vpiAssignmentPatternOp
# A zero OP67 on OUR side is only meaningful when OP75 is large — that is the
# positive control.  usage: dbcensus70.sh <workdir> [<dumpbin>]
set -u
W=${1:?workdir}; D=${2:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
S=$(dirname "$0")/shape70.py
op67=0; op75=0; n=0
while read -r f; do
  n=$((n+1))
  t=$(mktemp)
  timeout 120 "$D" "$f" > "$t" 2>/dev/null
  l=$(python3 "$S" "$t" 2>/dev/null)
  a=$(printf '%s\n' "$l" | grep -c '|PARAM .*|op67{' ; true)
  b=$(printf '%s\n' "$l" | grep -c '|PARAM .*|op75{' ; true)
  op67=$((op67+a)); op75=$((op75+b))
  [ "$a" -gt 0 ] && echo "OP67 $a  $f"
  rm -f "$t"
done < <(find "$W" -name slang.uhdm | sort)
echo "DBCENSUS $W databases=$n OP67cells=$op67 OP75cells=$op75"
