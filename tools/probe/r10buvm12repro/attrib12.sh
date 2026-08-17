#!/usr/bin/env bash
# r10buvm12repro/attrib12.sh — ATTRIBUTE EVERY BYTE MOVER, one database at a
# time, with the CALLEE-LINK census delta AND a whole-dump path-normalised
# diff.
#
#   usage: attrib12.sh <patched_wd_root> <pristine_wd_root> <rel/path/slang.uhdm> ...
#
# For each named database it prints:
#   * the census delta on the law's OWN field: how many `func_call`s gained a
#     `Function()` link between pristine and patched, and how many had one
#     already and got a DIFFERENT target (the prototype instead of the
#     out-of-body definition) -- keyed ID-blind and ADDRESS-blind on the parent
#     chain + kind + name + span;
#   * the whole-dump diff line counts with the workdir path and every id
#     normalised away.  A newly linked call adds `|vpiFunction:` plus the
#     SHALLOW `\_function: ...` print (2 lines) and a REDIRECTED call swaps one
#     shallow `\_function:` line for another (1 added, 1 removed), so the
#     verdict asserts `added == 2*gained + redirected`, `removed ==
#     redirected`, and that EVERY added and removed line is one of those two
#     forms.  A dump line that is neither is an unattributed change and FAILS.
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
CEN=/tmp/r10buvm12cen
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL no uhdm-dump $DUMP"; exit 3; }
bad=0
for rel in "$@"; do
  p=$B/$rel; q=$A/$rel
  [ -f "$p" ] && [ -f "$q" ] || { echo "== $rel : MISSING SIDE (p=$( [ -f "$p" ] && echo ok || echo no) q=$( [ -f "$q" ] && echo ok || echo no))"; bad=$((bad+1)); continue; }
  T=$(mktemp -d /tmp/r10buvm12_at_XXXXXX)
  "$CEN" "$p" P > "$T/p.cen" 2>&1; "$CEN" "$q" Q > "$T/q.cen" 2>&1
  # the law's own field, ID-blind: array_vars whose ELEMENT carries ranges
  # the law's own field, ID-blind: (key -> tl) for every tf_call on each side
  awk '$1=="TC"{k="";t="";for(i=1;i<=NF;i++){if($i ~ /^key=/)k=substr($i,5); else if($i ~ /^tl=/)t=substr($i,4)} print k"\t"t}' \
      "$T/p.cen" | LC_ALL=C sort > "$T/p.lnk"
  awk '$1=="TC"{k="";t="";for(i=1;i<=NF;i++){if($i ~ /^key=/)k=substr($i,5); else if($i ~ /^tl=/)t=substr($i,4)} print k"\t"t}' \
      "$T/q.cen" | LC_ALL=C sort > "$T/q.lnk"
  np=$(grep -cv $'\t-$' "$T/p.lnk" || true)
  nq=$(grep -cv $'\t-$' "$T/q.lnk" || true)
  gained=$((nq-np))
  # a REDIRECT: the key had a link on BOTH sides and the target CHANGED
  redirected=$(LC_ALL=C join -t$'\t' "$T/p.lnk" "$T/q.lnk" 2>/dev/null |
      awk -F'\t' '$2!="-" && $3!="-" && $2!=$3' | wc -l)
  "$DUMP" "$p" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/p.dmp"
  "$DUMP" "$q" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/q.dmp"
  diff "$T/p.dmp" "$T/q.dmp" > "$T/draw" || true
  radd=$(grep -c '^>' "$T/draw" || true); rrem=$(grep -c '^<' "$T/draw" || true)
  LC_ALL=C sort "$T/p.dmp" > "$T/p.srt"; LC_ALL=C sort "$T/q.dmp" > "$T/q.srt"
  diff "$T/p.srt" "$T/q.srt" > "$T/d" || true
  add=$(grep -c '^>' "$T/d" || true); rem=$(grep -c '^<' "$T/d" || true)
  nr=$(grep -c '^>.*vpiFunction:' "$T/d" || true)
  nrg=$(grep -cE '^>[[:space:]]*\\_function: ' "$T/d" || true)
  other=$(grep '^>' "$T/d" | grep -vE 'vpiFunction:|\\_function: ' | wc -l)
  otherR=$(grep '^<' "$T/d" | grep -vE 'vpiFunction:|\\_function: ' | wc -l)
  echo "== $rel"
  echo "   census    : tf_calls carrying a callee link  pristine=$np patched=$nq  GAINED=$gained REDIRECTED=$redirected"
  echo "   dump RAW        : +$radd lines / -$rrem lines   (order-SENSITIVE; the documented vpiTaskFunc coin lives here)"
  echo "   dump ORDER-BLIND: +$add lines / -$rem lines   |vpiFunction:=$nr  \\_function:=$nrg  other-added=$other other-removed=$otherR   (expected +$((gained*2+redirected)) / -$redirected)"
  if [ "$rem" -ne "$redirected" ] || [ "$add" -ne $((gained*2+redirected)) ] ||
     [ "$other" -ne 0 ] || [ "$otherR" -ne 0 ] || [ "$nr" -ne "$gained" ] ||
     [ "$nrg" -ne $((gained+redirected)) ]; then
    echo "   NOT ATTRIBUTED: the dump delta is not exactly $gained new links + $redirected redirects"
    bad=$((bad+1))
  else
    echo "   ATTRIBUTED: $gained callee links added, $redirected redirected, nothing else changed"
  fi
  rm -rf "$T"
done
echo "-- databases NOT ATTRIBUTED: $bad"
[ "$bad" -eq 0 ]
