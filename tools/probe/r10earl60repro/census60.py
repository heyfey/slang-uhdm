#!/usr/bin/env python3
"""r10earl60 — vpiInstance census over a uhdm-dump.

The dump is a COLUMN-INDENTED tree.  uhdm-dump keeps a GLOBAL visited set
(templates/vpi_visitor.cpp:483), so every object's FULL subtree is printed
exactly ONCE, at the first place the walk reaches it; every later reference
prints the header line ALONE.  That makes the dump a unique-object view, which
is what lets this census key on (owner kind, owner name, owner span) without
double counting -- but it also means an object with NO child lines is
AMBIGUOUS (a genuine leaf or a shallow re-reference), so those are counted in
their own bucket and never mixed with the full prints.

Emits, per section (DEF = uhdmall*, ELAB = uhdmtop*, TAIL = weaklyReferenced):
  (owner_kind, owner_name, owner_span, instance_kind, instance_name) -> count
"""
import re, sys, collections

HDR = re.compile(r'^( *)\\_([A-Za-z_0-9]+): (.*)$')
REL = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
# strip the file: field (absolute paths) but KEEP name and span
def norm(hdr):
    return re.sub(r', file:[^,]*', '', hdr)

def sectionof(rel):
    if rel.startswith('uhdmall'): return 'DEF'
    if rel.startswith('uhdmtop'): return 'ELAB'
    if rel == 'weaklyReferenced': return 'TAIL'
    return None

def run(path):
    stack = []          # list of [col, kind, hdr, nchild, rel]
    cur_rel = None
    section = 'PRE'
    out = collections.Counter()
    leafct = collections.Counter()
    pending = None      # (kind, hdr) awaiting its |vpiInstance: target
    for line in open(path, errors='replace'):
        line = line.rstrip('\n')
        if line == '\\_weaklyReferenced:':
            while stack:
                fin = stack.pop()
                if fin[3] == 0: leafct[(fin[5], fin[1])] += 1
            section = 'TAIL'; cur_rel = None; continue
        m = HDR.match(line)
        if m:
            col = len(m.group(1)); kind = m.group(2); hdr = norm(m.group(3))
            if col == 0:
                s = sectionof(cur_rel or '')
                if s: section = s
            while stack and stack[-1][0] >= col:
                fin = stack.pop()
                if fin[3] == 0:
                    leafct[(fin[5], fin[1])] += 1
            if stack:
                stack[-1][3] += 1
                if stack[-1][4] == 'vpiInstance':
                    # the OWNER is the object the relation tag hangs under,
                    # i.e. the CURRENT stack top -- not its parent.
                    own = stack[-1]
                    out[(own[5], own[1], own[2], kind, hdr)] += 1
            stack.append([col, kind, hdr, 0, cur_rel, section])
            cur_rel = None
            continue
        m = REL.match(line)
        if m:
            col = len(m.group(1)); tag = m.group(2); val = m.group(3)
            if col == 0:
                cur_rel = tag
                continue
            while stack and stack[-1][0] >= col:
                fin = stack.pop()
                if fin[3] == 0:
                    leafct[(fin[5], fin[1])] += 1
            if val == '':
                cur_rel = tag
                if stack: stack[-1][4] = tag
            else:
                if stack: stack[-1][3] += 1; stack[-1][4] = None
                cur_rel = None
            continue
    while stack:
        fin = stack.pop()
        if fin[3] == 0:
            leafct[(fin[5], fin[1])] += 1
    return out, leafct

if __name__ == '__main__':
    out, leafct = run(sys.argv[1])
    with open(sys.argv[2], 'w') as f:
        for k, v in sorted(out.items()):
            f.write('%s\t%s\t%s\t%s\t%s\t%d\n' % (k[0], k[1], k[2], k[3], k[4], v))
    with open(sys.argv[2] + '.leaf', 'w') as f:
        for k, v in sorted(leafct.items()):
            f.write('%s\t%s\t%d\n' % (k[0], k[1], v))
    tot = sum(out.values())
    bysec = collections.Counter()
    for k, v in out.items(): bysec[k[0]] += v
    print(sys.argv[1], 'vpiInstance edges total', tot, dict(bysec))
