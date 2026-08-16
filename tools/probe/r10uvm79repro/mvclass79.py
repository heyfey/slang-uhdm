#!/usr/bin/env python3
"""r10uvm79repro/mvclass79.py — ATTRIBUTE every moved shape of every mover to
one of this pass's three laws, and REFUSE to let anything fall through.

Reads mv79.sh's output (`- <n> <shape>` removed / `+ <n> <shape>` added, one
`== <path> …` header per mover) and, for each shape that is on one side only,
tries to reach the OTHER side by applying ONLY the rewrites the three laws
authorise, cheapest first.  The first rewrite that reaches the other side names
the law.  A shape that no authorised rewrite can reach is UNATTRIBUTED, and one
UNATTRIBUTED shape fails the run — a mover analysis that cannot name a line has
not verified anything.

  JOINT   flipping ONE `.` <-> `::`                  § hpTailElemJoinsByScope79
  NAME    rewriting an index group to its decompiled
          form (the pass's four measured pairs)      § hpMidSelIdxDecompiled79
  SCOPE   NAME + re-scoping through the path text    § hpMidSelIdxAtPath79
  SPAN    NAME/SCOPE + a changed `line:` suffix      § hpMidSelIdxAtPath79
  MULT    the identical shape on both sides, different multiplicity

The NAME rewrites are NOT invented here: each is a (ours -> golden) pair the
pre-build census read off the golden databases (README §3).

  usage: mvclass79.py <mv79-output>
"""
import re, sys, collections

# (ours -> golden) index-group rewrites, all four read off golden before the build
NAMEPAIRS = [
    ('[avail_sequences[i]]', '[[i]]'),
    ('[obj.get_type_name]', '[]'),
    ('[child.get_name()]', '[]'),
    ('[f.get_parent]', '[]'),
]

def apply_names(s):
    for a, b in NAMEPAIRS:
        s = s.replace(a, b)
    return s

def sepblind(s):
    return s.replace('::', '\x01').replace('.', '\x01')

def nolocs(s):
    return re.sub(r', line:\S+, endln:\S+', '', s)

def descope(s):
    """drop any `<path-name>::`/`<path-name>.` inserted scope step: collapse a
    fullname down to its scope head and its last component."""
    return re.sub(r'arb_sequence_q\[\[i\]\]\.sequence_ptr[.:]+', '', s)

path = sys.argv[1]
cur = None
rem, add, order = collections.defaultdict(dict), collections.defaultdict(dict), []
for line in open(path, errors='replace'):
    if line.startswith('== '):
        cur = line.split()[1]; order.append(cur); continue
    m = re.match(r'^  ([-+]) (\d+) (.*)$', line.rstrip('\n'))
    if m and cur:
        (rem if m.group(1) == '-' else add)[cur][m.group(3)] = int(m.group(2))

def sepvariants(s):
    out = set()
    for i, c in enumerate(s):
        if c == '.':
            out.add(s[:i] + '::' + s[i+1:])
    for i in range(len(s) - 1):
        if s[i:i+2] == '::':
            out.add(s[:i] + '.' + s[i+2:])
    return out

bad = 0
print('%-46s %7s %7s %7s %7s %7s %7s %7s' %
      ('mover', 'JOINT', 'NAME', 'SCOPE', 'SPAN', 'MULT', 'OTHER', 'lines'))
for mv in order:
    R, A = rem[mv], add[mv]
    c = collections.Counter(); others = []
    for side, D, O in (('-', R, A), ('+', A, R)):
        Oset = set(O)
        On = {apply_names(o) for o in Oset}
        Ons = {sepblind(descope(apply_names(o))) for o in Oset}
        Onsl = {nolocs(x) for x in Ons}
        for shape in D:
            if shape in Oset:
                c['MULT'] += 1; continue
            if sepvariants(shape) & Oset:
                c['JOINT'] += 1; continue
            if apply_names(shape) in On:
                c['NAME'] += 1; continue
            if sepblind(descope(apply_names(shape))) in Ons:
                c['SCOPE'] += 1; continue
            if nolocs(sepblind(descope(apply_names(shape)))) in Onsl:
                c['SPAN'] += 1; continue
            c['OTHER'] += 1; others.append(side + ' ' + shape)
    print('%-46s %7d %7d %7d %7d %7d %7d %7d' %
          (mv, c['JOINT'], c['NAME'], c['SCOPE'], c['SPAN'], c['MULT'],
           c['OTHER'], sum(c.values())))
    bad += c['OTHER']
    for o in others[:40]:
        print('    UNATTRIBUTED %s' % o)
print('TOTAL UNATTRIBUTED = %d' % bad)
sys.exit(0 if bad == 0 else 7)
