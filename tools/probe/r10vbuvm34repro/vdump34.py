#!/usr/bin/env python3
# r10vbuvm34repro/vdump34.py — an INDEPENDENT, VIEW-GENERAL reader of
# uhdm-dump text.  Parses the indentation tree, SKIPS every `vpiParent:`
# subtree (the dump renders one level of the parent inline, which a naive walk
# double-counts), and emits two MULTISET families:
#
#   FELV  one row per (foreach_stmt, loop-variable SLOT)
#         key     = source line:col of the foreach + SLOT + loop-var vpiName
#         payload = loop-var KIND, its actual typespec KIND and NAME, and the
#                   ARRAY reference's KIND / vpiName / Path_elems count+kinds
#   REFB  one row per body reference whose vpiName equals some loop-var name
#         key     = source line:col + name;  payload = bound? + bound KIND
#
# The key never carries the parenthesised vpiFullName (no generated Compare
# reads it) and never a per-line last writer.  MEASUREMENT ONLY.
import re, sys, collections

NODE = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+):\s*(?:\(([^)]*)\))?(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)')

class N:
    __slots__ = ('kind','fn','loc','fields','scalars')
    def __init__(self, kind, fn, loc):
        self.kind = kind; self.fn = fn; self.loc = loc
        self.fields = collections.defaultdict(list)   # name -> [N]
        self.scalars = {}

def parse(path):
    roots = []
    # stack of (indent, node); pending field name per indent
    stack = []
    pending = {}
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        m = NODE.match(line)
        if m:
            ind = len(m.group(1)); kind = m.group(2); fn = m.group(3) or ''
            lm = LOC.search(m.group(4) or '')
            loc = f"{lm.group(1)}:{lm.group(2)}" if lm else ''
            n = N(kind, fn, loc)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if stack:
                par = stack[-1][1]; f = pending.get(ind, '?')
                par.fields[f].append(n)
            else:
                roots.append(n)
            stack.append((ind, n))
            continue
        m = FIELD.match(line)
        if m:
            ind = len(m.group(1)); name = m.group(2); val = m.group(3)
            pending[ind] = name
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if stack and val != '':
                stack[-1][1].scalars[name] = val
            continue
    return roots

def walk(n, fn=None, seen=None):
    """depth-first over the REAL tree: vpiParent subtrees are skipped."""
    yield n
    for f, kids in n.fields.items():
        if f == 'vpiParent':
            continue
        for k in kids:
            yield from walk(k)

def actual_ts(v):
    """the loop variable's ACTUAL typespec (through ref_typespec)."""
    for rt in v.fields.get('vpiTypespec', []):
        if rt.kind == 'ref_typespec':
            for a in rt.fields.get('vpiActual', []):
                return a
        else:
            return rt
    return None

def arrdesc(fs):
    vs = fs.fields.get('vpiVariables', [])
    if not vs:
        return ('-', '-', '-')
    v = vs[0]
    nm = v.scalars.get('vpiName', '')
    pe = v.fields.get('vpiPathElems', []) or v.fields.get('Path_elems', [])
    if v.kind == 'hier_path':
        pe = [c for f, ks in v.fields.items() if f not in ('vpiParent','vpiTypespec') for c in ks]
    return (v.kind, nm, f"{len(pe)}[{','.join(k.kind for k in pe)}]")

def rows(path, tag):
    out = []
    lvnames = set()
    roots = parse(path)
    for r in roots:
        for n in walk(r):
            if n.kind != 'foreach_stmt':
                continue
            ak, an, ap = arrdesc(n)
            lvs = n.fields.get('vpiLoopVars', [])
            for i, v in enumerate(lvs):
                ts = actual_ts(v)
                nm = v.scalars.get('vpiName', '')
                if nm: lvnames.add(nm)
                out.append(('FELV', n.loc, str(i), nm,
                            v.kind,
                            (ts.kind if ts else '-'),
                            (ts.fn if ts else '-'),
                            # the typespec's OWN span and vpiSigned are part of
                            # the payload: sharing the declaration's spanned,
                            # signed object where golden mints a BARE one is a
                            # real difference the boundary sees (vg19c).
                            (ts.loc if ts else '-') + '/' +
                            (ts.scalars.get('vpiSigned','-') if ts else '-'),
                            ak, an, ap))
    for r in roots:
        for n in walk(r):
            if n.kind not in ('ref_obj','ref_var'):
                continue
            nm = n.scalars.get('vpiName', '')
            if nm not in lvnames:
                continue
            act = n.fields.get('vpiActual', [])
            out.append(('REFB', n.loc, '-', nm,
                        n.kind, ('Y' if act else 'N'),
                        (act[0].kind if act else '-'), '-', '-', '-'))
    return out

if __name__ == '__main__':
    for r in rows(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else 'X'):
        print('\t'.join(r))
