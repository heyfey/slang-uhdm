#!/bin/bash
# grid.sh <pristine binary> <law binary> <out file> [case dir ...]: every case (default: every dut.sv dir under
# cases/) in both views (EL=0, EL=1): pristine, law, and law under R11U234_OFF=1. One line per case-view:
#   <case><_el> P rc=<rc> strict=<verdict> md5=<8> | L rc= strict= md5= | OFF md5=<8> offeq=<0|1>
# (case.sh lines; offeq=1 when R11U234_OFF writes the pristine bytes). Fail-closed on $FENCED; tools guarded by case.sh.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
: "${GW:?export GW}"
P=$1; L=$2; OUT=$3; shift 3
for b in "$P" "$L"; do [ -x "$b" ] || { echo "grid.sh: $b not executable" >&2; exit 2; }; done
DR=$(cd "$(dirname "$0")" && pwd); CD=$(cd "$DR/../cases" && pwd)
LIST=$(mktemp "${GW}/gridlist.XXXXXX")
if [ $# -gt 0 ]; then for c in "$@"; do echo "$c"; done > $LIST; else find $CD -name dut.sv -printf '%h\n' | sort > $LIST; fi
for n in $FENCED; do grep -qw "$n" $LIST && { echo "grid.sh: fenced name in the case list" >&2; rm -f $LIST; exit 2; }; done
one() {
  local c=$1 el=$2 tp tl to
  tp=$(EL=$el bash $DR/case.sh $c pris $P </dev/null)
  tl=$(EL=$el bash $DR/case.sh $c law $L </dev/null)
  to=$(EL=$el bash $DR/case.sh $c off $L R11U234_OFF=1 </dev/null)
  local mp=$(echo "$tp" | grep -o 'md5=[0-9a-f]*' | cut -d= -f2) mo=$(echo "$to" | grep -o 'md5=[0-9a-f]*' | cut -d= -f2)
  local eq=0; [ -n "$mp" ] && [ "$mp" = "$mo" ] && eq=1
  echo "$tp | $(echo "$tl" | cut -d' ' -f2-) | OFF md5=$mo offeq=$eq"
}
export -f one; export DR P L
N=0
while read -r c <&3; do
  for el in 0 1; do
    one $c $el &
    N=$((N+1)); if [ $((N % 3)) = 0 ]; then wait; fi
  done
done 3< $LIST > $OUT.tmp
wait
sort $OUT.tmp > $OUT; rm -f $OUT.tmp $LIST
echo "grid.sh: $(wc -l < $OUT) case-views, listed $(( $(find $CD -name dut.sv | wc -l) * 2 )) (all) " >&2
