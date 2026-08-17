#!/usr/bin/env bash
# r10buvm10repro/attrib10.sh — ATTRIBUTE EVERY BYTE MOVER, one database at a
# time, with the alias-edge delta AND a whole-dump path-normalised diff.
#
#   usage: attrib10.sh <patched_wd_root> <pristine_wd_root> <rel/path/slang.uhdm> ...
#
# For each named database it prints:
#   * the alias-edge delta (ID-blind key: actual kind:name, ref fullname, parent
#     chain) between pristine and patched — the law's own field;
#   * the whole-dump diff line counts with the workdir path and every id
#     normalised away, and the count of ADDED vpiTypedefAlias blocks and of
#     REMOVED lines.  A mover with a non-zero REMOVED count or a dump delta that
#     is not exactly 7 lines per alias block is NOT attributed and says so.
set -u
A=${1:?patched wd root}; B=${2:?pristine wd root}; shift 2
CEN=/tmp/r10buvm10cen
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL no uhdm-dump $DUMP"; exit 3; }
bad=0
for rel in "$@"; do
  p=$B/$rel; q=$A/$rel
  [ -f "$p" ] && [ -f "$q" ] || { echo "== $rel : MISSING SIDE (p=$( [ -f "$p" ] && echo ok || echo no) q=$( [ -f "$q" ] && echo ok || echo no))"; bad=$((bad+1)); continue; }
  T=$(mktemp -d /tmp/r10buvm10_at_XXXXXX)
  "$CEN" "$p" P > "$T/p.cen" 2>&1; "$CEN" "$q" Q > "$T/q.cen" 2>&1
  "$DUMP" "$p" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/p.dmp"
  "$DUMP" "$q" 2>/dev/null | sed -E "s#$B/##g; s#$A/##g; s/, id:[0-9]+//g; s/#[0-9]+//g" |
      grep -v 'Restored design' > "$T/q.dmp"
  diff "$T/p.dmp" "$T/q.dmp" > "$T/draw" || true
  radd=$(grep -c '^>' "$T/draw" || true); rrem=$(grep -c '^<' "$T/draw" || true)
  # THE VERDICT IS TAKEN ORDER-BLIND, and this is a CORRECTION MADE BY THE
  # VERIFIER, not a preference.  The standing MEASUREMENT LAWS say
  # "Scoreboard/default is a ~50/50 COIN (svunit_pkg vpiTaskFunc reorder) --
  # attribute only by order-blind census", and this script judged the RAW diff.
  # MEASURED: on the verifier's own build of the SAME two binaries
  # (pristine 8b5e2f68abfc42dfb43c389faa929c83 / patched
  # 1cbb4c34040e4bca0facc551818533e1) default/Scoreboard read
  # `+67 / -46  NOT ATTRIBUTED` -- a FALSE ALARM produced entirely by the coin,
  # since the same pair reads `+21 / -0`, exactly 3 alias blocks, once the two
  # dumps are sorted.  A gate whose verdict depends on a coin flip is not a
  # gate.  BOTH numbers are printed so an ORDER regression is still visible;
  # only the ORDER-BLIND one decides.
  LC_ALL=C sort "$T/p.dmp" > "$T/p.srt"; LC_ALL=C sort "$T/q.dmp" > "$T/q.srt"
  diff "$T/p.srt" "$T/q.srt" > "$T/d" || true
  add=$(grep -c '^>' "$T/d" || true); rem=$(grep -c '^<' "$T/d" || true)
  nal=$(grep -c '^>.*vpiTypedefAlias' "$T/d" || true)
  echo "== $rel"
  echo "   dump RAW        : +$radd lines / -$rrem lines   (order-SENSITIVE; a nonzero delta here with a clean line below is the documented vpiTaskFunc coin)"
  echo "   dump ORDER-BLIND: +$add lines / -$rem lines   ADDED vpiTypedefAlias blocks=$nal   (7 lines per block => expected +$((nal*7)))"
  python3 "$(dirname "$0")/aldelta10.py" "$T/p.cen" P "$T/q.cen" Q | sed 's/^/   /'
  if [ "$rem" -ne 0 ] || [ "$add" -ne $((nal*7)) ]; then
    echo "   NOT ATTRIBUTED: the dump delta is not purely $nal alias blocks"
    bad=$((bad+1))
  else
    echo "   ATTRIBUTED: $nal Typedef_alias additions, nothing removed, nothing else changed"
  fi
  rm -rf "$T"
done
echo "-- databases NOT ATTRIBUTED: $bad"
[ "$bad" -eq 0 ]
