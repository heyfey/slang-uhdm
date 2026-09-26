#!/bin/bash
# coin.sh <a.uhdm> <b.uhdm>: dump line count difference and ORDER-BLIND difference (ids stripped, sorted)
A1=$1; A2=$2; source /tmp/v11u178_env.sh; set -- "$A1" "$A2"
for n in $FENCED; do echo "$1 $2" | grep -qw "$n" && { echo refuse; exit 3; }; done
T=/tmp/v11u178_coin.$$; mkdir -p $T
$UHDM_DUMP $1 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/tmp/v11u178_[A-Za-z0-9_]+/##g' > $T/a
$UHDM_DUMP $2 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/tmp/v11u178_[A-Za-z0-9_]+/##g' > $T/b
d=$(diff $T/a $T/b | grep -c '^[<>]'); o=$(diff <(sort $T/a) <(sort $T/b) | grep -c '^[<>]')
echo "dump_lines_diff=$d orderblind_diff=$o"; [ -n "${SHOW:-}" ] && diff <(sort $T/a) <(sort $T/b) | head -${SHOW}
rm -rf $T
