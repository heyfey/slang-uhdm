#!/usr/bin/env bash
# r10buvm11repro/attrib11.sh — ATTRIBUTE EVERY BYTE MOVER, one database at a
# time, with the element-range census delta AND a whole-dump path-normalised
# diff.
#
#   usage: attrib11.sh <patched_wd_root> <pristine_wd_root> <rel/path/slang.uhdm> ...
#
# For each named database it prints:
#   * the census delta on the law's OWN field: how many array_vars gained an
#     element `Ranges` vector between pristine and patched, keyed ID-blind and
#     ADDRESS-blind on the parent chain + name + span;
#   * the whole-dump diff line counts with the workdir path and every id
#     normalised away.  A stamped element adds EXACTLY TWO dump lines
#     (`|vpiRange:` and the shallow `\_range: ...` line -- the range object
#     itself is already printed under the array_var, because it IS the same
#     object), so the arithmetic the verdict asserts is `added == 2 * gained`
#     and `removed == 0`, with every added line required to be one of those two
#     forms.
#
# THE VERDICT IS TAKEN ORDER-BLIND, and that is a CORRECTION THE buvm10 VERIFIER
# MADE, not a preference: the standing MEASUREMENT LAWS say
# "Scoreboard/default is a ~50/50 COIN (svunit_pkg vpiTaskFunc reorder) --
# attribute only by order-blind census", and the inherited script judged the RAW
# diff, which reported a FALSE `NOT ATTRIBUTED` on that row.  BOTH numbers are
# printed so an ORDER regression is still visible; only the ORDER-BLIND one
# decides.
set -u
A=${1:?patched wd root}; B=${2:?pristine wd root}; shift 2
CEN=/tmp/r10buvm11cen
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL no uhdm-dump $DUMP"; exit 3; }
bad=0
for rel in "$@"; do
  p=$B/$rel; q=$A/$rel
  [ -f "$p" ] && [ -f "$q" ] || { echo "== $rel : MISSING SIDE (p=$( [ -f "$p" ] && echo ok || echo no) q=$( [ -f "$q" ] && echo ok || echo no))"; bad=$((bad+1)); continue; }
  T=$(mktemp -d /tmp/r10buvm11_at_XXXXXX)
  "$CEN" "$p" P > "$T/p.cen" 2>&1; "$CEN" "$q" Q > "$T/q.cen" 2>&1
  # the law's own field, ID-blind: array_vars whose ELEMENT carries ranges
  np=$(awk '$1=="AV"{for(i=1;i<=NF;i++) if($i ~ /^evR=/ && substr($i,5)+0 >= 1) print}' "$T/p.cen" | wc -l)
  nq=$(awk '$1=="AV"{for(i=1;i<=NF;i++) if($i ~ /^evR=/ && substr($i,5)+0 >= 1) print}' "$T/q.cen" | wc -l)
  gained=$((nq-np))
  "$DUMP" "$p" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/p.dmp"
  "$DUMP" "$q" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/q.dmp"
  diff "$T/p.dmp" "$T/q.dmp" > "$T/draw" || true
  radd=$(grep -c '^>' "$T/draw" || true); rrem=$(grep -c '^<' "$T/draw" || true)
  LC_ALL=C sort "$T/p.dmp" > "$T/p.srt"; LC_ALL=C sort "$T/q.dmp" > "$T/q.srt"
  diff "$T/p.srt" "$T/q.srt" > "$T/d" || true
  add=$(grep -c '^>' "$T/d" || true); rem=$(grep -c '^<' "$T/d" || true)
  nr=$(grep -c '^>.*vpiRange:' "$T/d" || true)
  nrg=$(grep -cE '^>[[:space:]]*\\_range: ' "$T/d" || true)
  other=$(grep '^>' "$T/d" | grep -vE 'vpiRange:|\\_range: ' | wc -l)
  echo "== $rel"
  echo "   census    : array_vars with an element Ranges vector  pristine=$np patched=$nq  GAINED=$gained"
  echo "   dump RAW        : +$radd lines / -$rrem lines   (order-SENSITIVE; the documented vpiTaskFunc coin lives here)"
  echo "   dump ORDER-BLIND: +$add lines / -$rem lines   |vpiRange:=$nr  \\_range:=$nrg  other=$other   (expected +$((gained*2)))"
  if [ "$rem" -ne 0 ] || [ "$add" -ne $((gained*2)) ] || [ "$other" -ne 0 ] ||
     [ "$nr" -ne "$gained" ] || [ "$nrg" -ne "$gained" ]; then
    echo "   NOT ATTRIBUTED: the dump delta is not exactly $gained shared-range stamps"
    bad=$((bad+1))
  else
    echo "   ATTRIBUTED: $gained element Ranges vectors added, nothing removed, nothing else changed"
  fi
  rm -rf "$T"
done
echo "-- databases NOT ATTRIBUTED: $bad"
[ "$bad" -eq 0 ]
