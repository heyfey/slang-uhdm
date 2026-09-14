#!/usr/bin/env python3
"""leftcen.py <gold.dump> [<a.dump> [<b.dump>]] -- THE LEFTOVER CENSUS.

Per (dump SECTION, struct_typespec name, struct-copy ORDINAL, member name)
prints the `typespec_member`'s stamped expression -- its object KIND and
exactly the fields `constant::Compare` reads (VpiValue / VpiSize /
VpiConstType / VpiDecompile) plus whether it carries a Typespec.  Values are
NEVER clipped (the r11vu13 measurement trap: two wide BINs differing only in
the middle read EQUAL through a clip).

A key ABSENT from a dump reads `<no-such-copy>` and a member present but
unstamped reads `<clean>` -- conflating the two once made our module-view
copies look unstamped when the dumper had simply not re-expanded a SHARED
object.  BACKREFERENCES are skipped: the uhdm-dump prints an object EXPANDED the first
time and as a bare one-line backref afterwards, and a naive indent walk counts
the backrefs as real children (it read every struct copy twice and every
stamp as clean).  An object counts as expanded only when the next non-blank
line is deeper-indented.

With two or three dumps it JOINS on the key and scores each cell
TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / SAME-WRONG / SAME-RIGHT.
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_(\w+): ?(?:\((.*?)\))?')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
VAL = re.compile(r'^(UINT|INT|BIN|DEC|HEX|OCT|STRING|REAL|SINT|IINT)$')


def indent(s):
    return len(s) - len(s.lstrip())


def expanded(lines, i):
    n = indent(lines[i])
    j = i + 1
    while j < len(lines) and not lines[j].strip():
        j += 1
    return j < len(lines) and indent(lines[j]) > n


def obj_fields(lines, i):
    """Fields printed directly under the object opened at line i."""
    n = indent(lines[i])
    out = {'kind': OBJ.match(lines[i]).group(2), 'val': '', 'size': '',
           'ct': '', 'dec': '', 'ts': '-', 'ops': 0}
    j = i + 1
    while j < len(lines):
        s = lines[j]
        if not s.strip():
            break
        if indent(s) <= n:
            break
        mf = FLD.match(s)
        if mf and indent(s) == n + 2:
            f, v = mf.group(2), mf.group(3)
            if VAL.match(f):
                out['val'] = f + ':' + v
            elif f == 'vpiSize':
                out['size'] = v
            elif f == 'vpiConstType':
                out['ct'] = v
            elif f == 'vpiDecompile':
                out['dec'] = v
            elif f == 'vpiTypespec':
                out['ts'] = 'TS'
            elif f == 'vpiOperand':
                out['ops'] += 1
        j += 1
    return out


def parse(path):
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    sec = '?'
    stack = []          # (indent, kind, name)
    copyno = {}         # (sec, tsname) -> next ordinal
    cells = {}
    cur = None          # (sec, tsname, ordinal)
    for i, l in enumerate(lines):
        if l.startswith('|uhdm') and l.endswith(':'):
            sec = l.strip('|:')
            stack = []
            cur = None
            continue
        m = OBJ.match(l)
        if not m:
            continue
        n, kind, nm = len(m.group(1)), m.group(2), m.group(3) or ''
        if not expanded(lines, i):
            continue
        while stack and stack[-1][0] >= n:
            stack.pop()
        parent = stack[-1] if stack else None
        stack.append((n, kind, nm))
        if kind == 'struct_typespec':
            o = copyno.get((sec, nm), 0)
            copyno[(sec, nm)] = o + 1
            cur = (sec, nm, o)
        elif kind == 'typespec_member' and parent and \
                parent[1] == 'struct_typespec' and cur:
            # first |vpiExpr: directly under this member
            j, got = i + 1, None
            while j < len(lines) and lines[j].strip() and indent(lines[j]) > n:
                mf = FLD.match(lines[j])
                if mf and indent(lines[j]) == n + 2 and mf.group(2) == 'vpiExpr':
                    if j + 1 < len(lines) and OBJ.match(lines[j + 1]) and \
                            expanded(lines, j + 1):
                        got = obj_fields(lines, j + 1)
                        break
                j += 1
            cells[(cur[0], cur[1], cur[2], nm)] = got or 'CLEAN'
    return cells


def render(c):
    if c is None:
        return '<no-such-copy>'
    if c == 'CLEAN':
        return '<clean>'
    return ('%s val=%s size=%s ct=%s dec=%s ts=%s ops=%d'
            % (c['kind'], c['val'], c['size'], c['ct'], c['dec'], c['ts'],
               c['ops']))


def main():
    paths = sys.argv[1:]
    if not paths:
        sys.exit('usage: leftcen.py <gold.dump> [<a.dump> [<b.dump>]]')
    dumps = [parse(p) for p in paths]
    if len(dumps) == 1:
        for k in sorted(dumps[0]):
            print('%-18s %-26s #%d %-14s | %s'
                  % (k[0], k[1], k[2], k[3], render(dumps[0][k])))
        return
    g = dumps[0]
    keys = set()
    for d in dumps:
        keys |= set(d)
    tally = {}
    for k in sorted(keys):
        cg = render(g.get(k))
        ca = render(dumps[1].get(k))
        cb = render(dumps[2].get(k)) if len(dumps) > 2 else ca
        if len(dumps) > 2:
            if ca == cb:
                verdict = 'SAME-RIGHT' if ca == cg else 'SAME-WRONG'
            elif cb == cg:
                verdict = 'TO-GOLDEN'
            elif ca == cg:
                verdict = 'AWAY-GOLDEN'
            else:
                verdict = 'MOVED-WRONG'
        else:
            verdict = 'MATCH' if ca == cg else 'DIFF'
        tally[verdict] = tally.get(verdict, 0) + 1
        if verdict in ('SAME-RIGHT', 'MATCH'):
            continue
        print('%-12s %-18s %-26s #%d %s' % (verdict, k[0], k[1], k[2], k[3]))
        print('        GOLD %s' % cg)
        print('        A    %s' % ca)
        if len(dumps) > 2:
            print('        B    %s' % cb)
    print('TALLY ' + ' '.join('%s=%d' % (k, v) for k, v in sorted(tally.items())))


main()
