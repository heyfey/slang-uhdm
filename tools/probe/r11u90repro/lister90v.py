#!/usr/bin/env python3
"""v11u90 SHAPE LISTER — per-holder net and cont_assign listings from a
uhdm-dump, scored PER CELL.  A holder is a module_inst / interface_inst /
program_inst DEFINITION line; the listing is the |vpiNet: / |vpiContAssign:
entries at that holder's own indent.  Unresolvable rows are printed UNSCORED,
never silently dropped.  usage: v11u90_lister.py <dump> [dump2]"""
import re, sys, collections

HOLDER = re.compile(r'^(\s*)\\_(module_inst|interface_inst|program_inst): +(\S+) +\(([^)]*)\)')
FIELD = re.compile(r'^(\s*)\|(vpiNet|vpiContAssign|vpiProcess):')
ENTRY = re.compile(r'^(\s*)\\_(\w+): *(\(([^)]*)\))?,? *(.*)$')


def listing(path):
    """holder-fullname -> {field -> [entry strings]}"""
    out = collections.defaultdict(lambda: collections.defaultdict(list))
    lines = open(path, errors='replace').read().split('\n')
    stack = []          # (indent, fullname)
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = HOLDER.match(ln)
        if m:
            ind, kind, defn, full = m.group(1), m.group(2), m.group(3), m.group(4)
            # only DEFINITION occurrences carry a following |vpiFullName at ind+2
            stack = [(a, b) for (a, b) in stack if a < len(ind)]
            stack.append((len(ind), full))
            i += 1
            continue
        f = FIELD.match(ln)
        if f and stack:
            ind, field = len(f.group(1)), f.group(2)
            holder = None
            for (a, b) in reversed(stack):
                if ind == a + 2:
                    holder = b
                    break
            if holder is None:
                i += 1
                continue
            j = i + 1
            if j < len(lines):
                e = ENTRY.match(lines[j])
                if e and len(e.group(1)) == ind:
                    name = e.group(4) or ''
                    loc = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', e.group(5) or '')
                    loc = (loc.group(1) + '-' + loc.group(2)) if loc else '?'
                    out[holder][field].append('%s|%s|%s' % (e.group(2), name, loc))
                else:
                    out[holder][field].append('UNSCORED:' + lines[j].strip()[:60])
        i += 1
    return out


def show(path):
    L = listing(path)
    for h in sorted(L):
        for fld in sorted(L[h]):
            if fld == 'vpiProcess':
                continue
            for e in L[h][fld]:
                print('%-34s %-14s %s' % (h, fld, e))


if __name__ == '__main__':
    if len(sys.argv) == 2:
        show(sys.argv[1])
    else:
        A, B = listing(sys.argv[1]), listing(sys.argv[2])
        for h in sorted(set(A) | set(B)):
            for fld in ('vpiNet', 'vpiContAssign'):
                a, b = A.get(h, {}).get(fld, []), B.get(h, {}).get(fld, [])
                # multiset-safe pairing: count, never dict-overwrite
                ca, cb = collections.Counter(a), collections.Counter(b)
                for k in sorted(set(ca) | set(cb)):
                    if ca[k] == cb[k]:
                        tag = 'MATCH' if ca[k] else ''
                    elif ca[k] and not cb[k]:
                        tag = 'GOLD-ONLY'
                    elif cb[k] and not ca[k]:
                        tag = 'OURS-ONLY'
                    else:
                        tag = 'COUNT %d/%d' % (ca[k], cb[k])
                    if tag and tag != 'MATCH':
                        print('%-30s %-14s %-9s %s' % (h, fld, tag, k))
