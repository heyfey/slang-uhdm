#!/usr/bin/env bash
# r10earl58 dmov56.sh — THE WHOLE-DUMP MOVER READER, and the reason it exists is
# a caught regression, not tidiness.
#
# `census56.py` keys on a select's BOUND SLOTS and reads each slot's DIRECT
# child.  It is therefore structurally BLIND to a reference NESTED INSIDE a bound
# OPERATION — the slot reads `operation` on both sides whatever happens below it.
# The first build of § genScopeOwnParamNoSelFold56 broke 107 such cells at
# prim_fifo_sync.sv:127:48 and the census reported AWAY-GOLDEN = 0.
#
# This script diffs two dumps and NAMES every object that appeared or vanished,
# grouped by kind, by the identifier in its parenthesised name and by SOURCE
# LINE, so a mover cannot hide inside a big hunk.
#
# DUMP PATHS EMBED THE WORKDIR (earl55's trap): the two sides run in different
# directories, so every `file:` line differs and an un-normalised diff reports
# hundreds of module_inst "movers" that are pure path text.  Both sides are
# normalised to `<WD>` before the diff.  A fence check that cannot tell a path
# from a defect proves nothing.
#
#   usage: dmov56.sh <a.dump> <b.dump>       (a = pristine, b = patched)
set -u
A=${1:?a.dump}; B=${2:?b.dump}
[ -f "$A" ] && [ -f "$B" ] || { echo NO_DUMP; exit 3; }
NA=$(mktemp); NB=$(mktemp)
sed 's#/[^ ,]*/\([a-zA-Z0-9_.]*\.sv\)#<WD>/\1#g; s#/[^ ,]*/\([a-zA-Z0-9_.]*\.svh\)#<WD>/\1#g' "$A" > "$NA"
sed 's#/[^ ,]*/\([a-zA-Z0-9_.]*\.sv\)#<WD>/\1#g; s#/[^ ,]*/\([a-zA-Z0-9_.]*\.svh\)#<WD>/\1#g' "$B" > "$NB"
A=$NA; B=$NB
D=$(mktemp)
if diff "$A" "$B" > "$D"; then echo "DUMP_IDENTICAL"; rm -f "$D" "$NA" "$NB"; exit 0; fi
echo "changed-lines=$(grep -cE '^[<>]' "$D") hunks=$(grep -cE '^[0-9]' "$D")"
for side in '<' '>'; do
  case $side in '<') tag="REMOVED(pristine-only)";; '>') tag="ADDED(patched-only)";; esac
  echo "-- $tag objects by kind:"
  grep -E "^$side " "$D" | grep -oE '\\_[a-z_0-9]+:' | sort | uniq -c | sort -rn
  echo "-- $tag objects by (kind,name,line):"
  grep -E "^$side " "$D" | sed -n 's/.*\\_\([a-z_0-9]*\): *\(.*\)$/\1 \2/p' \
    | sed 's/\(.*\)(\(.*\)\.\([A-Za-z_0-9]*\)), line:\([0-9]*\):.*/\1 NAME=\3 LINE=\4/' \
    | sed 's/, endln.*//' | sed 's/line:\([0-9]*\):[0-9]*/LINE=\1/' \
    | sort | uniq -c | sort -rn | head -25
done
rm -f "$D" "$NA" "$NB"
