#!/usr/bin/env bash
# r10buvm13repro/attrib13.sh — ATTRIBUTE EVERY BYTE MOVER, one database at a
# time, with THIS LAW'S OWN census delta AND a whole-dump path-normalised diff.
#
#   usage: attrib13.sh <patched_wd_root> <pristine_wd_root> <rel/path/slang.uhdm> ...
#
# THE LAW'S OWN FIELD is `ref_obj::Actual_group()` for a ref inside an
# io_decl's DEFAULT VALUE, and it moves in BOTH directions:
#   GAINED  — a ref to an EARLIER FORMAL that now carries `vpiActual` -> the
#             formal's io_decl (package/module free subroutine, out-of-body
#             class-method definition, instantiated interface function);
#   LOST    — an enum_const (or any other) actual that an IN-CLASS listing
#             (in-body method, `extern` prototype, `pure virtual`) must NOT
#             carry, removed by the classMethodNoBind silence.
# A gained bind adds exactly two dump lines (`|vpiActual:` plus the SHALLOW
# `\_<kind>: ...` print) and a lost bind removes exactly two, so the verdict
# asserts `added == 2*GAINED`, `removed == 2*LOST`, and that EVERY added and
# removed line is one of those two forms.  Anything else is an unattributed
# change and FAILS.
#
# THE VERDICT IS TAKEN ORDER-BLIND (the standing MEASUREMENT LAWS:
# "Scoreboard/default is a ~50/50 COIN (task_func ORDER flip) — attribute ONLY
# order-blind").  BOTH numbers are printed so an ORDER regression is still
# visible; only the ORDER-BLIND one decides.
set -u
A=${1:?patched wd root}; B=${2:?pristine wd root}; shift 2
CEN=/tmp/r10buvm13cen
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL no uhdm-dump $DUMP"; exit 3; }
bad=0
for rel in "$@"; do
  p=$B/$rel; q=$A/$rel
  [ -f "$p" ] && [ -f "$q" ] || { echo "== $rel : MISSING SIDE"; bad=$((bad+1)); continue; }
  T=$(mktemp -d /tmp/r10buvm13_at_XXXXXX)
  "$CEN" "$p" P > "$T/p.cen" 2>&1; "$CEN" "$q" Q > "$T/q.cen" 2>&1
  cnt() { awk '$1=="DV"{for(i=1;i<=NF;i++) if($i=="act=1") n++} END{print n+0}' "$1"; }
  np=$(cnt "$T/p.cen"); nq=$(cnt "$T/q.cen")
  # GAINED / LOST are counted key by key, not as a net figure: a database that
  # gained 3 and lost 3 must not read as "nothing moved".
  key() { awk '$1=="DV"{k="";a="";for(i=1;i<=NF;i++){if($i ~ /^key=/)k=substr($i,5); else if($i ~ /^act=/)a=substr($i,5)} print k"\t"a}' "$1" | LC_ALL=C sort; }
  key "$T/p.cen" > "$T/p.k"; key "$T/q.cen" > "$T/q.k"
  # LC_ALL=C ON `comm` TOO, not only on the `sort` that feeds it: the two must
  # agree on collation or comm prints "file N is not in sorted order" ON STDERR
  # and returns GARBAGE that still looks like numbers.  (It did, first run.)
  gained=$(LC_ALL=C comm -13 "$T/p.k" "$T/q.k" | awk -F'\t' '$2=="1"' | wc -l)
  lost=$(LC_ALL=C comm -13 "$T/p.k" "$T/q.k" | awk -F'\t' '$2=="0"' | wc -l)
  "$DUMP" "$p" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/p.dmp"
  "$DUMP" "$q" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/q.dmp"
  diff "$T/p.dmp" "$T/q.dmp" > "$T/draw" || true
  radd=$(grep -c '^>' "$T/draw" || true); rrem=$(grep -c '^<' "$T/draw" || true)
  LC_ALL=C sort "$T/p.dmp" > "$T/p.srt"; LC_ALL=C sort "$T/q.dmp" > "$T/q.srt"
  diff "$T/p.srt" "$T/q.srt" > "$T/d" || true
  add=$(grep -c '^>' "$T/d" || true); rem=$(grep -c '^<' "$T/d" || true)
  nact=$(grep -c '^>.*vpiActual:' "$T/d" || true)
  nactR=$(grep -c '^<.*vpiActual:' "$T/d" || true)
  nsh=$(grep -cE '^>[[:space:]]*\\_[a-z_]+: ' "$T/d" || true)
  nshR=$(grep -cE '^<[[:space:]]*\\_[a-z_]+: ' "$T/d" || true)
  other=$(grep '^>' "$T/d" | grep -vE 'vpiActual:|\\_[a-z_]+: ' | wc -l)
  otherR=$(grep '^<' "$T/d" | grep -vE 'vpiActual:|\\_[a-z_]+: ' | wc -l)
  echo "== $rel"
  echo "   census    : default-value refs carrying an ACTUAL  pristine=$np patched=$nq   GAINED=$gained LOST=$lost"
  echo "   dump RAW        : +$radd / -$rrem   (order-SENSITIVE; the documented vpiTaskFunc coin lives here)"
  # THE LINE MODEL, and why it is not simply 2 lines per moved bind.  A bind
  # prints TWO dump lines: the MARKER `|vpiActual:` and the SHALLOW
  # `\_<kind>: (name), line:...` print of the target.  The order-blind diff is a
  # MULTISET diff of line TEXT, and every marker line is the SAME text, so the
  # gained and lost markers CANCEL and only the NET survives.  The shallow lines
  # do not cancel (they carry the target's kind, name and span).  So:
  #     shallow-added   == GAINED
  #     shallow-removed == LOST
  #     (marker-removed - marker-added) == LOST - GAINED
  #     nothing else changed at all
  echo "   dump ORDER-BLIND: +$add / -$rem   marker +$nact/-$nactR  shallow +$nsh/-$nshR  other +$other/-$otherR   (expected shallow +$gained/-$lost, marker net -$((lost-gained)))"
  if [ "$nsh" -ne "$gained" ] || [ "$nshR" -ne "$lost" ] ||
     [ $((nactR-nact)) -ne $((lost-gained)) ] ||
     [ "$other" -ne 0 ] || [ "$otherR" -ne 0 ]; then
    echo "   NOT ATTRIBUTED: the dump delta is not exactly $gained gained + $lost lost default-value actuals"
    bad=$((bad+1))
  else
    echo "   ATTRIBUTED: $gained default-value actuals added, $lost removed, nothing else changed"
  fi
  rm -rf "$T"
done
echo "-- databases NOT ATTRIBUTED: $bad"
[ "$bad" -eq 0 ]
