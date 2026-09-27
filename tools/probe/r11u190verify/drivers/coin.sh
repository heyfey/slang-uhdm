#!/bin/bash
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
# coin.sh <a.uhdm> <b.uhdm>: dump-line difference in order and ORDER-BLIND (ids and the sweep directories stripped,
# sorted) -- the UVM UINT/vpiDecompile order coin reads 0 or 4 order-blind lines.  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "coin.sh: source drivers/env.sh" >&2; exit 2; }
for n in $FENCED; do echo "$1 $2" | grep -qw "$n" && { echo refuse; exit 3; }; done
T=/tmp/r11u190_coin.$$; mkdir -p $T
$UHDM_DUMP $1 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/tmp/r11u190_[A-Za-z0-9_]+/##g' > $T/a
$UHDM_DUMP $2 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/tmp/r11u190_[A-Za-z0-9_]+/##g' > $T/b
d=$(diff $T/a $T/b | grep -c '^[<>]'); o=$(diff <(sort $T/a) <(sort $T/b) | grep -c '^[<>]')
echo "dump_lines_diff=$d orderblind_diff=$o"; [ -n "${SHOW:-}" ] && diff <(sort $T/a) <(sort $T/b) | head -${SHOW}
rm -rf $T
