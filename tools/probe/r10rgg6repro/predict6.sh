#!/usr/bin/env bash
# r10rgg6/predict6.sh — PREDICT THE MOVER SET BY NAME, from the PRISTINE side
# alone, BEFORE the patched binary is run over a corpus.
#
#   usage: predict6.sh {src|db} <arg> <outfile>
#     src <corpus-root>   source-level over-approximation (seconds)
#     db  <base-workdir>  database-level exact set (dumps every database)
#
# WHY TWO MODES.  The law can only touch the `vpiTypespec` of a `func_call`
# that is a `param_assign`'s Rhs, and such an object exists only where the
# source declares a parameter whose initializer IS a function call.  The `src`
# scan is therefore a SOUND OVER-APPROXIMATION: a test with no such declaration
# in any of its sources cannot move, whatever its database looks like.  It costs
# seconds, where `db` costs a uhdm-dump of every database in the corpus
# (Earlgrey_0_1 alone runs minutes and writes a multi-GB text file — that is why
# the cheap mode exists and why the expensive one is opt-in).
#
# GUARD: `src` prints the number of DIRECTORIES scanned as well as the number of
# hits, so an empty result can be told apart from a scan that reached nothing.
set -u
mode=${1:?src|db}
case "$mode" in
  src)
    ROOT=${2:?corpus root}
    OUT=${3:?outfile}
    : > "$OUT"
    ndir=0
    while IFS= read -r d; do
      ndir=$((ndir+1))
      # a parameter/localparam declaration whose initializer is a CALL:
      #   [local]param[eter] <anything> NAME = ident(
      h=$(grep -rEl '^[[:space:]]*(localparam|parameter)\b.*=[[:space:]]*[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\(' \
            --include='*.v' --include='*.sv' --include='*.svh' --include='*.vh' \
            "$d" 2>/dev/null | head -3)
      [ -n "$h" ] && printf 'CANDIDATE-DIR %s\n%s\n' "$d" "$h" >> "$OUT"
    done < <(find "$ROOT" -type d)
    echo "-- dirs scanned=$ndir candidate dirs=$(grep -c '^CANDIDATE-DIR' "$OUT" || true)" >> "$OUT"
    ;;
  db)
    WD=${2:?workdir}
    OUT=${3:?outfile}
    HERE=$(cd "$(dirname "$0")" && pwd)
    DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
    : > "$OUT"
    n=0; sc=0
    for f in "$WD"/*/*/slang.uhdm; do
      [ -f "$f" ] || continue
      sc=$((sc+1))
      rel=${f#$WD/}; rel=${rel%/slang.uhdm}
      T=$(mktemp /tmp/r10rgg6_pred.XXXXXX)
      "$DUMP" "$f" 2>/dev/null > "$T" || { rm -f "$T"; continue; }
      k=$(python3 "$HERE/dumpscan.py" "$T" calls 2>/dev/null |
          awk -F'\t' '$6=="ts"' | wc -l)
      rm -f "$T"
      if [ "$k" -gt 0 ]; then
        echo "CANDIDATE $rel  param_assign-Rhs func_calls WITH ts = $k" >> "$OUT"
        n=$((n+1))
      fi
    done
    echo "-- candidates=$n scanned=$sc" >> "$OUT"
    ;;
esac
