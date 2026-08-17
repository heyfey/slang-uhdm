#!/usr/bin/env python3
"""r10earl58 — THE GRID READER.

For every OCCURRENCE of a named parameter in an arm's SOURCE, report what each
dump holds at that occurrence's own line:col, in each VIEW, together with the
slot it fills and its parent's kind.  LHS is always golden.

WHY A SOURCE-DRIVEN KEY.  The question this pass asks is "did golden replace
THIS identifier with a constant?", and the identifier is a SOURCE object, not a
dump object: a `ref_obj` and its substituted `constant` share the identifier's
span and nothing else, so a span key taken from the source lines them up
whatever the surrounding tree does.  v56span3.py's structural key answers a
different question (did any object in this slot change) and is BLIND when one
side has no object at all -- the ONLY-A / ONLY-B buckets.

  usage: grid58.py <arm.sv> <golden.dump> [<ours.dump>] [NAME,NAME,...]
"""
import re, sys, collections

HDR = re.compile(r'^(\s*)\\_([a-z_0-9]+): *(.*)$')
SLOT = re.compile(r'^(\s*)\|(vpi[A-Za-z0-9_]+|uhdm[A-Za-z0-9_]+):\s*$')
KEEP = ('vpiDecompile', 'vpiSize', 'vpiConstType', 'UINT', 'INT', 'HEX', 'BIN')

def parse(path, spans):
    """-> {(view, line, col): [ 'kind/slot/parentkind[payload]' ... ] }"""
    out = collections.defaultdict(list)
    lines = open(path, errors='replace').read().split('\n')
    stack, view, cur_slot, slot_ind, prev_slot = [], None, None, -1, False
    for i, line in enumerate(lines):
        s = line.strip()
        if s == '|uhdmtopModules:':
            view, stack, cur_slot, slot_ind, prev_slot = 'ELAB', [], 'top', 0, True
            continue
        if s == '|uhdmallModules:':
            view, stack, cur_slot, slot_ind, prev_slot = 'DEF', [], 'all', 0, True
            continue
        if view is None:
            continue
        m = SLOT.match(line)
        if m:
            cur_slot, slot_ind, prev_slot = m.group(2), len(m.group(1)), True
            continue
        m = HDR.match(line)
        if not m:
            if s:
                prev_slot = False
            continue
        owned = prev_slot
        prev_slot = False
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        pk = stack[-1][1] if stack else 'root'
        stack.append((ind, kind))
        if not owned:
            continue
        slot = cur_slot if (cur_slot is not None and slot_ind <= ind) else '?'
        if slot == 'vpiParent':
            continue
        msp = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
        if not msp:
            continue
        # THE EXACT EXTENT, not just the start.  `v[L1-1:0]`'s operation begins
        # at the SAME column as its `L1` operand, so a start-only key merges the
        # identifier's object with the operation's and reports `constant` for a
        # cell where the identifier is still a `ref_obj`.
        key = (view, int(msp.group(1)), int(msp.group(2)), int(msp.group(4)))
        if key[1:] not in spans:
            continue
        pay = []
        for j in range(i + 1, min(i + 20, len(lines))):
            l2 = lines[j]
            if not l2.strip():
                continue
            i2 = len(l2) - len(l2.lstrip(' '))
            if i2 <= ind:
                break
            if i2 != ind + 2:
                continue
            m2 = re.match(r'^\s*\|([A-Za-z0-9_]+):(.*)$', l2)
            if m2 and m2.group(1) in KEEP and m2.group(2).strip():
                pay.append('%s=%s' % (m2.group(1), m2.group(2).strip()))
        out[key].append('%s/%s/%s[%s]' % (kind, slot, pk, ','.join(pay)))
    return out

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    src = open(args[0]).read().split('\n')
    dumps = [a for a in args[1:] if a.endswith('.dump')]
    names = set(args[-1].split(',')) if not args[-1].endswith('.dump') else None
    occ = {}
    for i, l in enumerate(src, 1):
        for m in re.finditer(r'\b([A-Za-z_]\w*)\b', l):
            if names is None or m.group(1) in names:
                occ[(i, m.start() + 1, m.end() + 1)] = (m.group(1), l.strip())
    spans = set(occ)
    ds = [parse(d, spans) for d in dumps]
    tal = collections.Counter()
    for k in sorted(occ):
        nm, txt = occ[k]
        cells = []
        for d in ds:
            e = d.get(('ELAB',) + k, [])
            cells.append(';'.join(sorted(set(e))) or '-')
        if all(c == '-' for c in cells):
            continue
        verdict = 'SAME' if len(set(cells)) == 1 else 'DIFF'
        tal[verdict] += 1
        print('%-4s %-10s %4d:%-3d %s | %s' %
              (verdict, nm, k[0], k[1], '  ||  '.join(cells), txt[:90]))
    print('-- ' + ' '.join('%s=%d' % (x, tal[x]) for x in sorted(tal)))

main()
