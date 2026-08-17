#!/usr/bin/env python3
"""r10earl56 — per-CELL bound reader.

Reads a uhdm-dump (with line 1 already stripped) and, for every `cont_assign`
or procedural `assignment` in the ELAB (`uhdmtopModules`) or DEF
(`uhdmallModules`) listing, reports the KIND of each select-bound slot it
contains, keyed by the assignment's LHS name.

Why a cell reader and not a dump diff: the law under test decides ONE slot per
cell (`ref_obj` vs `constant`), and a dump diff cannot tell a slot that moved
from a span that moved.  Keys are (view, lhs-name, slot), never a line number.

  usage: grid56.py <dump> [<dump2>]        one dump = table; two = 3-column join
"""
import re, sys, collections

SLOTS = ("vpiBaseExpr", "vpiWidthExpr", "vpiLeftRange", "vpiRightRange",
         "vpiIndex")

def indent(l):
    return len(l) - len(l.lstrip(' '))

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    view = None
    # (view, lhs, slot) -> "kind[:detail]"
    out = collections.OrderedDict()
    occ = {}
    # find assignment blocks: a line whose stripped form starts with
    # `\_cont_assign:` or `\_assignment:`; block = following lines with a
    # STRICTLY greater indent.
    i = 0
    n = len(lines)
    while i < n:
        l = lines[i]
        s = l.strip()
        if 'uhdmtopModules' in s:
            view = 'ELAB'
        elif 'uhdmallModules' in s:
            view = 'DEF'
        m = re.match(r'\\_(cont_assign|assignment):', s)
        if not m:
            i += 1
            continue
        base = indent(l)
        j = i + 1
        blk = []
        while j < n and (lines[j].strip() == '' or indent(lines[j]) > base):
            blk.append(lines[j])
            j += 1
        # LHS name: the vpiName under the vpiLhs slot, else vpiFullName tail
        lhs = None
        for k, b in enumerate(blk):
            if b.strip() == '|vpiLhs:':
                for b2 in blk[k+1:k+12]:
                    mm = re.match(r'\|vpiFullName:(.*)$', b2.strip())
                    if mm:
                        lhs = mm.group(1).strip()
                        break
                if lhs:
                    break
        if lhs is None:
            lhs = '<anon@%d>' % (i + 1)
        # THE INSTRUMENT CORRECTION that had to be made before any number was
        # believed: the ELAB listing holds each gen-scope cont_assign TWICE (the
        # instance-scoped copy under the module_inst, and a second flat copy
        # whose refs are scoped `gen_norm.din` and carry no vpiActual).  Keying
        # on the LHS fullname alone MERGED them and reported the SECOND copy's
        # answer for the first -- i.e. exactly the opposite of golden's.  The
        # occurrence index is part of the key.
        occ[(view, lhs)] = occ.get((view, lhs), 0) + 1
        lhs = '%s@%d' % (lhs, occ[(view, lhs)])
        # every slot occurrence in the block, in order; the object kind is the
        # NEXT `\_kind:` line
        cnt = collections.Counter()
        for k, b in enumerate(blk):
            sb = b.strip()
            sl = sb[1:-1] if sb.startswith('|') and sb.endswith(':') else None
            if sl not in SLOTS:
                continue
            kind = det = ''
            for b2 in blk[k+1:k+2]:
                mm = re.match(r'\\_([a-z_0-9]+):', b2.strip())
                if mm:
                    kind = mm.group(1)
            if kind == 'constant':
                for b2 in blk[k+1:k+8]:
                    mm = re.match(r'\|((?:U?INT|BIN|HEX|OCT|DEC)):(\S*)', b2.strip())
                    if mm:
                        det = mm.group(1) + ':' + mm.group(2)
            elif kind == 'ref_obj':
                for b2 in blk[k+1:k+8]:
                    mm = re.match(r'\|vpiName:(.*)$', b2.strip())
                    if mm:
                        det = mm.group(1).strip()
                        break
            cnt[sl] += 1
            key = (view, lhs, '%s#%d' % (sl, cnt[sl]))
            out[key] = kind + ('(' + det + ')' if det else '')
        i = j
    return out

def main():
    a = parse(sys.argv[1])
    if len(sys.argv) == 2:
        for (v, l, s), k in a.items():
            print('%-4s %-52s %-16s %s' % (v, l, s, k))
        print('-- cells=%d' % len(a))
        return
    b = parse(sys.argv[2])
    keys = list(a.keys()) + [k for k in b if k not in a]
    same = diff = onlya = onlyb = 0
    for k in keys:
        va, vb = a.get(k), b.get(k)
        if va is None:
            onlyb += 1; tag = 'ONLY-B'
        elif vb is None:
            onlya += 1; tag = 'ONLY-A'
        elif va == vb:
            same += 1; tag = 'same'
        else:
            diff += 1; tag = 'DIFF'
        if tag != 'same':
            print('%-6s %-4s %-52s %-16s A=%-28s B=%s' %
                  (tag, k[0], k[1], k[2], va, vb))
    print('-- same=%d DIFF=%d ONLY-A=%d ONLY-B=%d' % (same, diff, onlya, onlyb))

main()
