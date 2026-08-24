#!/usr/bin/env bash
# r10v119repro — see README.md §"How to re-run". MEASUREMENT ONLY.
# Order-blind regression detector: a line that golden and PRISTINE both have,
# in multiset terms, but PATCHED lost  => LOST-CORRECT.
# A line PATCHED has that golden does not, and pristine did not have either
# => NEW-SURPLUS.
set -u
D=$1
norm() { tail -n +2 "$1" | sed 's/^[[:space:]]*//' | sort; }
for v in def elab; do
  g=$D/dump.g.$v.txt; a=$D/dump.a.$v.txt; b=$D/dump.b.$v.txt
  [ -s "$g" ] || { echo "$v NOGOLD"; continue; }
  norm $g > /tmp/v119_r.g; norm $a > /tmp/v119_r.a; norm $b > /tmp/v119_r.b
  # multiset intersection golden&pristine
  comm -12 /tmp/v119_r.g /tmp/v119_r.a > /tmp/v119_r.ga
  lost=$(comm -23 /tmp/v119_r.ga /tmp/v119_r.b | wc -l)
  # surplus in patched not in golden
  comm -13 /tmp/v119_r.g /tmp/v119_r.b > /tmp/v119_r.sb
  comm -13 /tmp/v119_r.g /tmp/v119_r.a > /tmp/v119_r.sa
  newsurp=$(comm -23 /tmp/v119_r.sb /tmp/v119_r.sa | wc -l)
  gained=$(comm -23 <(comm -12 /tmp/v119_r.g /tmp/v119_r.b) /tmp/v119_r.a | wc -l)
  echo "$v LOST-CORRECT=$lost NEW-SURPLUS=$newsurp GAINED-CORRECT=$gained"
  if [ "$lost" != 0 ]; then echo "   --- LOST:"; comm -23 /tmp/v119_r.ga /tmp/v119_r.b | head -20 | sed 's/^/     /'; fi
  if [ "$newsurp" != 0 ]; then echo "   --- NEW SURPLUS:"; comm -23 /tmp/v119_r.sb /tmp/v119_r.sa | head -20 | sed 's/^/     /'; fi
done
