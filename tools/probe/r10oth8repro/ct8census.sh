#!/usr/bin/env bash
# r10oth8 — THE PER-FIELD CENSUS, which is the instrument that shows the law
# working.  "cmp lines are a HEAD-DEPTH measure, dump content is a ROUGH
# DISTANCE, and PER-FIELD CENSUSES are what show a law working."
#
#   usage: ct8census.sh <workdir-root> <mode> <test>
#
# For ONE test it counts, on BOTH sides and at OWN CHILD DEPTH:
#   (1) array_var objects carrying `vpiSigned` on THEMSELVES;
#   (2) array_var objects whose NESTED element var carries `vpiSigned` -- AND
#       READ THIS NUMBER WITH ct8nested.py BESIDE IT, because column (2) MIXES
#       TWO OPPOSITE LAWS: golden puts `vpiSigned` on the ELEMENT at
#       SUBROUTINE-LOCAL scope and on the ARRAY at class/module scope, so a
#       single count can move toward golden in one population and stay put in
#       the other and read as "away from golden" overall.  That is not a
#       hypothetical: on SeqDriver this column reads ours 25 -> 12 against a
#       golden of 23, and the SPLIT is member 19 -> 6 (fixed) with local
#       14 -> 14 (untouched).  `ct8nested.py` prints that split BY NAME;
#   (3) the total array_var population, so (1) and (2) are fractions of a
#       denominator and not free-floating counts.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# TRAPS ENCODED: uhdm-dump's line 1 is the DATABASE PATH (`sed 1d` on both);
# a missing database prints UNMEASURED and exits 3 rather than reporting zeros;
# the golden path is READ OUT of the workdir's own cmds.txt (`golden cache hit
# <dir>`), never guessed; and a bare test name is globbed to its hashed
# directory, with NO-SUCH-TEST distinguished from UNMEASURED.
set -u
ROOT=${1:?workdir root}
MODE=${2:-default}
NAME=${3:?test name}
HERE=$(cd "$(dirname "$0")" && pwd)
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
D=""
if [ -f "$ROOT/$MODE/$NAME/cmds.txt" ]; then D="$ROOT/$MODE/$NAME"; else
  for c in "$ROOT/$MODE/$NAME"-*; do [ -f "$c/cmds.txt" ] && D="$c"; done
fi
[ -n "$D" ] || { echo "NO-SUCH-TEST: $NAME under $ROOT/$MODE"; exit 1; }
G=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$D/cmds.txt")
if [ ! -f "$G/golden.uhdm" ] || [ ! -f "$D/slang.uhdm" ]; then
  echo "UNMEASURED: golden=[$G/golden.uhdm] ours=[$D/slang.uhdm]"; exit 3
fi
W=$(mktemp -d)
"$UD" "$G/golden.uhdm" 2>/dev/null | sed 1d > "$W/g.dump"
"$UD" "$D/slang.uhdm"  2>/dev/null | sed 1d > "$W/o.dump"
[ -s "$W/g.dump" ] && [ -s "$W/o.dump" ] || { echo UNMEASURED; exit 3; }
# CT8DIR, not a baked-in path: the first draft of this script had this
# worktree's ABSOLUTE path substituted into the heredoc, which would have
# shipped a probe that only runs in a directory that no longer exists.
export CT8DIR=$HERE
python3 - "$W/g.dump" "$W/o.dump" "$NAME/$MODE" <<'PY'
import os
import sys
sys.path.insert(0, os.environ['CT8DIR'])
from ct8fields import HDR, objects, own_and_nested


def census(dump):
    lines = open(dump, encoding='utf-8', errors='replace').readlines()
    seen = {}
    for i, ind, hdr in objects(lines, 'array_var', ''):
        own, refs, nested = own_and_nested(lines, i, ind)
        # OBJECT KEY = the header text AFTER the `\_array_var:` marker, i.e. the
        # parenthesised name plus the line/endln span -- INDENTATION STRIPPED.
        # THIS LINE WAS THE DEFECT (verifier F3, found at integration): it read
        # `hdr.split(', ')[0]` on the RAW line, so the leading spaces were part
        # of the key and one object printed at two depths counted as TWO.  The
        # column was published as "array_var objects" and was inflated ~2.6-2.8x
        # (SVSwitch 12 where `uhdm-dump --stats` says 5).  `ct8nested.py` had the
        # same bug and was fixed; this script was not, which is why the campaign
        # law "an object is not a dump occurrence" gets restated here at the key.
        m8 = HDR.match(hdr)
        key = (m8.group(3) if m8 else hdr.strip()).split(', line:')[0] + \
            '|' + ', '.join(p for p in (m8.group(3) if m8 else '').split(', ')
                            if p.startswith(('line:', 'endln:')))
        score = len(own) + len(refs)
        if key in seen and seen[key][0] >= score:
            continue
        seen[key] = (score, own, nested)
    tot = own_s = nest_s = 0
    for _k, (_s, own, nested) in seen.items():
        tot += 1
        if 'vpiSigned' in dict(own):
            own_s += 1
        if any(fn == 'vpiSigned' for _o, fn, _v in nested):
            nest_s += 1
    return tot, own_s, nest_s


g, o, tag = sys.argv[1], sys.argv[2], sys.argv[3]
gt, go, gn = census(g)
ot, oo, on = census(o)
print('%-28s | array_var objects | own vpiSigned | nested-elem vpiSigned' % tag)
print('%-28s | golden %-9d | golden %-6d | golden %d' % ('', gt, go, gn))
print('%-28s | ours   %-9d | ours   %-6d | ours   %d' % ('', ot, oo, on))
PY
rm -rf "$W"
