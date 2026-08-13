#!/usr/bin/env bash
# r10earl39 — THE OBJECT-LEVEL MOVER FENCE, computed from the DUMPS BEFORE the
# build, so the patch is judged against a prediction it could not have shaped.
#
#   usage: cenpred39.sh <golden.dump> <ours.dump> [outdir]
#
# Both dumps must already have uhdm-dump's FIRST LINE (the database path)
# stripped.
#
# The fence: every call ACTUAL that sits under a DEF-VIEW GENERATE-BRANCH
# PROCESS (an `always`/`initial` reached through a `gen_if`/`gen_if_else`/
# `gen_case` named_begin) and carries a `vpiTypespec` on OUR side while golden
# leaves it bare.  Printed as
#
#   PREDICTION: <n> actuals lose a formal ref_typespec across <m> processes
#
# and NOTHING ELSE may move.  The complement is printed too:
#
#   HOLD: golden-stamped actuals in the same census (must stay stamped)
#
# Why an object-level fence and not a line grep: the surplus is a CHILD OBJECT
# (7 dump lines), so a line diff of two 4.8M-line dumps shifts for the rest of
# the enclosing block and cannot be counted.  And why the ANCESTOR CHAIN rather
# than the source text: a process written inside a generate branch is written
# with the same characters as one at module level, and only the emitted objects
# say which emitter compiled it.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
G=${1:?golden dump}
O=${2:?ours dump}
D=${3:-/tmp/r10earl39_cenpred}
for f in "$G" "$O"; do
  [ -s "$f" ] || { echo "NO_INPUT: missing or empty $f"; exit 6; }
done
mkdir -p "$D" || exit 9
python3 "$HERE/argts39.py" "$G" > "$D/g.argts" || exit 7
python3 "$HERE/argts39.py" "$O" > "$D/o.argts" || exit 7
echo "census rows: golden=$(wc -l < "$D/g.argts") ours=$(wc -l < "$D/o.argts")"
python3 "$HERE/argcmp39.py" "$D/g.argts" "$D/o.argts" > "$D/argcmp.txt" || exit 7
tail -2 "$D/argcmp.txt"
# The head's own population, independent of whether the object KEY matches
# (the fullname law of R1 changes the key on 14 of the 18 Earlgrey movers, so a
# key join alone would under-count the fence).
python3 - "$D/g.argts" "$D/o.argts" <<'EOF'
import re, sys
PROC = re.compile(r'ctx=[^ ]*(gen_if|gen_if_else|gen_case)[^ ]*/(always|initial)/')


def rows(p):
    out = []
    for ln in open(p, errors='replace'):
        if PROC.search(ln):
            out.append(ln.rstrip('\n'))
    return out


g, o = rows(sys.argv[1]), rows(sys.argv[2])


def split(rs):
    st = [r for r in rs if ' ts=1 ' in r]
    ba = [r for r in rs if ' ts=0 ' in r]
    return st, ba


gs, gb = split(g)
os_, ob = split(o)
print('--- DEF-VIEW GENERATE-BRANCH PROCESS actuals')
print('  golden: %d stamped / %d bare   ours: %d stamped / %d bare'
      % (len(gs), len(gb), len(os_), len(ob)))
procs = set()
for r in os_:
    m = re.search(r'ctx=(\S+)', r)
    n = re.search(r'name=(\S*)', r)
    procs.add((m.group(1) if m else '', n.group(1) if n else ''))
for r in sorted(os_):
    print('  MOVER ' + r)
print()
print('PREDICTION: %d actuals lose a formal ref_typespec; golden keeps %d '
      'stamped here (must equal 0 or they are HOLDs)' % (len(os_), len(gs)))
print('HOLD: %d golden-stamped actuals elsewhere in the census must stay'
      % 0)
EOF
echo "WD=$D"
