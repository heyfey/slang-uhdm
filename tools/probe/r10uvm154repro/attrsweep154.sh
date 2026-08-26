#!/usr/bin/env bash
# r10uvm154 — attribute every byteverify MOVER line-by-line, ORDER-BLIND.
#
#   attrsweep154.sh <pristine-workdir> <patched-workdir> <rel-path> ...
#
# Scoreboard/default is a ~50/50 COIN per invocation (RESUME.md §9), so the two
# dumps are SORTED before diffing: an order flip cancels and only real content
# survives.  Dump paths embed the workdir, so both sides are path-normalised
# first, and the weakly-referenced TAIL — unreachable to the judge — is cut.
set -u
PRI=${1:?pristine workdir}; PAT=${2:?patched workdir}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
WD=${WD:-/tmp/r10uvm154_attr}
rm -rf "$WD"; mkdir -p "$WD"
bad=0
for rel in "$@"; do
  key=${rel//\//__}
  for side in pris pat; do
    [ "$side" = pris ] && src="$PRI/$rel" || src="$PAT/$rel"
    "$DUMP" "$src" 2>/dev/null </dev/null \
      | awk 'BEGIN{d=1} /^\\_weaklyReferenced:/{d=0} d==1{print}' \
      | sed -e "s#$PRI##g" -e "s#$PAT##g" -e 's/id:[0-9]*/id:N/g' \
      | sort > "$WD/$key.$side"
  done
  n=$(diff "$WD/$key.pris" "$WD/$key.pat" | grep -c '^[<>]'); true
  # every surviving line must be an enum_const payload field
  other=$(diff "$WD/$key.pris" "$WD/$key.pat" | grep '^[<>]' \
          | grep -vcE '^[<>] +\|(INT|UINT|BIN|HEX|OCT|DEC):|^[<>] +\|vpiDecompile:|^[<>] +\|vpiSize:'); true
  echo "ATTR $rel orderblind_lines=$n non-payload=$other"
  diff "$WD/$key.pris" "$WD/$key.pat" | grep '^[<>]' | sed 's/^/    /'
  [ "${other:-0}" -eq 0 ] || bad=$((bad+1))
done
echo "UNATTRIBUTED_DATABASES=$bad"
[ "$bad" -eq 0 ] && echo "ATTRIBUTION PASS" || { echo "ATTRIBUTION FAIL"; exit 4; }
