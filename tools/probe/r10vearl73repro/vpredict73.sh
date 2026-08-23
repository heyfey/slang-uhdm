#!/usr/bin/env bash
# r10v73 — PREDICT the byte-mover set BY NAME from the PRISTINE databases only.
# Stage 1: a database can move only if golden and PRISTINE disagree on a
# param_assign Rhs (ct,value) cell — the field class § ovActReduceIntOp73 owns.
# The four slang-fenced tests are FENCED-SKIPped and never named.
set -u
WD=${1:?pristine workdir root}
OUT=${2:?out file}
CEN=${PACEN73:-/tmp/v73_bin/pacen73}
FENCE_RE=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$(dirname "$0")/canaudit.sh" | tr ' ' '|')
export FENCE_RE
: > "$OUT"
find "$WD" -name cmds.txt | sort | while read -r c; do
  d=$(dirname "$c"); rel=${d#$WD/}
  # FENCED: the four slang-fenced corpus tests are never dispatched and are
  # never NAMED here -- the pattern is READ from canaudit.sh's own fence list
  # (spelling them in a probe artifact is itself a FENCE-BREACH).
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$rel" | grep -Eq "$FENCE_RE"; then
    echo "FENCED-SKIP <one of the four slang-fenced tests>" >> "$OUT"; continue
  fi
  g=$(grep -oE '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]+' "$c" | head -1)
  o="$d/slang.uhdm"
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || { echo "NOGOLD $rel" >> "$OUT"; continue; }
  [ -f "$o" ] || { echo "NODB $rel" >> "$OUT"; continue; }
  "$CEN" "$g/golden.uhdm" 2>/dev/null | sed -E 's/.*\|\| //' | sort > /tmp/v73_p_g.$$
  "$CEN" "$o" 2>/dev/null            | sed -E 's/.*\|\| //' | sort > /tmp/v73_p_o.$$
  n=$(diff /tmp/v73_p_g.$$ /tmp/v73_p_o.$$ | grep -cE '^[<>]' || true)
  if [ "$n" -gt 0 ]; then echo "CANDIDATE $rel diffsides=$n" >> "$OUT"; else echo "CLEAN $rel" >> "$OUT"; fi
  rm -f /tmp/v73_p_g.$$ /tmp/v73_p_o.$$
done
