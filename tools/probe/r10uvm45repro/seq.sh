#!/bin/bash
# r10uvm45 — project ONE scope's listing line (from an r10uvm44ls dump) onto the
# bare ORDERED (kind:name) sequence, one entry per line, so two scopes' tables
# can be diffed against each other directly.  The scope-level dump keeps every
# entry on a single line, which makes a 123-entry table unreadable and makes an
# ORDER difference invisible; the -e (per-entry) dump prefixes an INDEX, so a
# single insertion shifts every later line and a diff counts the tail rather
# than the deficit.  This is the third projection and the one that answers
# "which entries" and "in what order".
#
# A design has ONE `module_inst ''/def` line per module (the def view's VpiName
# is empty), so a prefix can match several scopes.  `head -1` picked an n=0 line
# and the caller then computed its diffs from a one-entry sequence, i.e. a
# number that looked like a measurement; among matches this takes the LARGEST,
# and it prints the chosen line's n= to stderr so the choice is auditable.
#   usage: seq.sh <ls-dump.txt> <scope-prefix>
set -u
F=${1:?}
P=${2:?}
L=$(grep -F "$P" "$F" | sed -E 's/.* n=([0-9]+).*/\1 &/' | sort -rn | head -1 \
    | cut -d' ' -f2-)
[ -n "$L" ] && echo "seq.sh: [$P] -> ${L%% |*}" >&2
printf '%s\n' "$L" | sed 's/^[^|]*| //' | tr '|' '\n' \
  | sed 's/^ *//; s/ *$//' | grep -v '^$'
