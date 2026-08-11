#!/usr/bin/env bash
# vtab.sh -- the r10oth6 ARM TABLE: one row per class_defn / per named
# variable-ish object, BOTH SIDES, from a viarm.sh workdir.
#
#   usage: ./vtab.sh /tmp/r10oth6_arm_v1_vifprop [name-regex]
#
# LHS is ALWAYS golden; RHS is ALWAYS ours.  A cell that exists on exactly one
# side prints UNMEASURED(no such object on this side) -- the whole point, since
# THIS pass's defect was an object we did not emit at all.
set -u
D=$1
RE=${2:-'.'}
if [ ! -s "$D/g.dump" ] || [ ! -s "$D/o.dump" ]; then
  echo "UNMEASURED(no dumps in $D -- run viarm.sh first)"; exit 3
fi
python3 - "$D" "$RE" <<'PY'
import sys, re
d, rex = sys.argv[1], re.compile(sys.argv[2])

# The dump grammar: a payload header `\_<kind>: (<fullname>), line:...` sits at
# some indent; its FIELDS are `|vpiX:...` lines at indent+2.  A payload with no
# indent+2 line after it is a BACK-REFERENCE (printed by reference), not a
# definition -- r10oth5's caform.py DEF/REF rule, reused here.
HDR = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\),? ?)?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')

def load(p):
    rows = {}          # (kind, fullname) -> (span, sorted fields, DEF/REF)
    lines = open(p).read().split('\n')
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m:
            continue
        ind, kind, fn, tail = m.group(1), m.group(2), m.group(3) or '', m.group(4)
        span = ''
        sm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', tail)
        if sm:
            span = sm.group(1) + '-' + sm.group(2)
        # collect own fields at indent+2 until the indent drops back
        flds = []
        j = i + 1
        want = len(ind) + 2
        isdef = False
        while j < len(lines):
            f = FLD.match(lines[j])
            h = HDR.match(lines[j])
            cur = len(f.group(1)) if f else (len(h.group(1)) if h else None)
            if cur is None or cur < want:
                break
            isdef = True
            if f and len(f.group(1)) == want:
                v = f.group(3)
                if f.group(2) not in ('vpiParent',):
                    flds.append(f.group(2) + '=' + v.strip())
            j += 1
        key = (kind, fn)
        val = (span, ' '.join(flds), 'DEF' if isdef else 'REF')
        # keep the FIRST DEF seen; a later REF must not overwrite it
        if key not in rows or (rows[key][2] == 'REF' and val[2] == 'DEF'):
            rows[key] = val
    return rows

g, o = load(d + '/g.dump'), load(d + '/o.dump')
keys = sorted(k for k in set(g) | set(o) if rex.search(k[1] or k[0]))
if not keys:
    print('VTAB_BLIND: the name filter selected NOTHING on either side')
    sys.exit(3)
n = 0
def fmt(v):
    return 'UNMEASURED(no such object on this side)' if v is None else \
           '%-5s %-13s %s' % (v[2], v[0] or '(no span)', v[1])
for k in keys:
    gv, ov = g.get(k), o.get(k)
    if gv != ov:
        n += 1
    print('%s  %s' % k)
    print('    G| %s' % fmt(gv))
    print('    O| %s%s' % (fmt(ov), '   *** DIFF' if gv != ov else ''))
print('CELLS=%d DIFFERING=%d' % (len(keys), n))
PY
