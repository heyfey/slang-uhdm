#!/usr/bin/env bash
# r11u53 SUBSET PROVER — "MOVED-WRONG 0 / AWAY-GOLDEN 0", proved as a SET
# containment rather than as a count.
#
# A residue COUNT going down is compatible with the patch clearing twenty lines
# and introducing three new ones.  The gate's actual question is whether any
# divergence appeared that was not there before.  This compares the SET of
# divergence line-texts (golden-only `<` and ours-only `>`) under the pristine
# binary with the set under the patched one; `NOT-PRESENT-BEFORE` must be 0.
#
# Object IDS are stripped first: an id renumbers whenever a node changes kind
# (a `constant` becoming a `sys_func_call` shifts every later id), so raw text
# would report the whole tail of the dump as "new".  The dump's `line:col`
# anchors and field names carry the identity that matters here.
#
#   usage: subset53.sh <pristine rowdir> <patched rowdir>
# where each rowdir is a verify_golden.py per-test workdir.
set -u
P=${1:?pristine rowdir}; Q=${2:?patched rowdir}
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
t=$(mktemp -d)
bash "$R/dumpdiff53.sh" "$P" "$t/b" > "$t/b.line"
bash "$R/dumpdiff53.sh" "$Q" "$t/p" > "$t/p.line"
norm() { grep -E '^[<>]' "$1" | sed 's/, id:[0-9]*//g; s/id:[0-9]*//g; s/^\([<>]\) */\1 /; s/  */ /g' | sort -u; }
norm "$t/b.diff.txt" > "$t/bs"; norm "$t/p.diff.txt" > "$t/ps"
new=$(comm -13 "$t/bs" "$t/ps" | grep -c .; true)
echo "$(basename "$Q")"
echo "  pristine: $(cat "$t/b.line")"
echo "  patched : $(cat "$t/p.line")"
echo "  divergence texts: pristine=$(wc -l < "$t/bs") patched=$(wc -l < "$t/ps") NOT-PRESENT-BEFORE=$new"
[ "$new" != 0 ] && comm -13 "$t/bs" "$t/ps" | sed 's/^/    NEW /'
rm -rf "$t"
[ "$new" = 0 ]
