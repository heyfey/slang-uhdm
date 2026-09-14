#!/usr/bin/env python3
# r11u25 CENSUS / A-PRIORI MOVER PREDICTION — reads PRISTINE databases ONLY.
#
# Two SEPARABLE faces, counted separately, both a deliberate SUPERSET:
#
#   F1  the FILL-SIZE face.  An ELABORATED gen_scope `cont_assign` whose Rhs
#       is a `constant` at `vpiSize != -1` that LOOKS like this emitter's mint
#       of an unsized fill:
#         F1F  vpiDecompile is `'0` / `'1` / `'X` / `'Z`   (our '0/'x/'z mint)
#         F1O  the value is ALL ONES for its size           (our '1 mint, which
#              loses the `'1` decompile: UINT:<mask> ct 9, or BIN:<ones> ct 3)
#       It cannot see whether `bindVariable` finds the target (a module-body
#       namesake, a module/port Lhs reached from a gen scope), so it over-flags.
#
#   F2  the DROPPED-BINDING face.  An ELABORATED gen_scope `cont_assign` whose
#       Lhs is a whole `ref_obj` that ALREADY CARRIES a `vpiActual` (only such
#       a cell can LOSE one) and whose Rhs subtree holds ANY constant at
#       `vpiSize:-1` (`DetectUnsizedConstant`, UhdmWriter.cpp:2283-2293).
#       It cannot see the own-scope fence nor the namesake fence.
#
# NO SECTIONING — `|uhdmallModules:` / `|uhdmtopModules:` are REPEATED keys,
# not two contiguous sections (r11u19's own bug); the whole dump is walked,
# which only widens the superset.  `owner == gen_scope` selects the elaborated
# rows on its own: a definition-listing generate block owns its cont_assigns
# through a `named_begin`.
#
# usage: pred25.py <dump> [...]      ('-' reads stdin)
import re, sys


def _read(path):
    if path == '-':
        return sys.stdin.read().split('\n')
    return open(path, errors='replace').read().split('\n')


FILLDEC = {"'0", "'1", "'X", "'Z", "'x", "'z"}


def _allones(val, size):
    if size is None or size <= 0 or size > 4096:
        return False
    m = re.match(r'^(UINT|INT):(\d+)$', val)
    if m:
        try:
            return int(m.group(2)) == (1 << size) - 1
        except ValueError:
            return False
    m = re.match(r'^BIN:([01]+)$', val)
    if m:
        return len(m.group(1)) == size and set(m.group(1)) == {'1'}
    return False


def _obj(L, k):
    """(kind, fields dict) for the object whose header is at line k"""
    m = re.match(r'^ *\\_([a-z_]+):', L[k])
    if not m:
        return '?', {}
    kind = m.group(1)
    b = len(L[k]) - len(L[k].lstrip())
    f = {}
    z = k + 1
    while z < len(L) and (not L[z].strip() or len(L[z]) - len(L[z].lstrip()) > b):
        s = L[z].strip()
        if len(L[z]) - len(L[z].lstrip()) == b + 2:
            mm = re.match(r'^\|(vpiSize|vpiDecompile|vpiConstType):(.*)$', s)
            if mm:
                f[mm.group(1)] = mm.group(2)
            mv = re.match(r'^\|((?:U?INT|BIN|HEX|OCT|STRING|REAL):.*)$', s)
            if mv:
                f['VAL'] = mv.group(1)
        z += 1
    return kind, f


def scan(path, L=None):
    L = list(L) if L is not None else _read(path)
    hits = []
    for i, ln in enumerate(L):
        m = re.search(r'\\_cont_assign: , (?:file:\S+, )?line:(\d+):(\d+)', ln)
        if not m:
            continue
        if i and L[i - 1].strip() == '|vpiParent:':
            continue
        ind = len(ln) - len(ln.lstrip())
        owner = '?'
        lhskind = '?'
        act = False
        rk, rf = '?', {}
        uns = False
        j = i + 1
        rhs_at = None
        while j < len(L):
            s = L[j]
            k = len(s) - len(s.lstrip())
            if k <= ind:
                break
            t = s.strip()
            if t == '|vpiParent:' and owner == '?':
                owner = L[j + 1].strip().split(':')[0].lstrip('\\_')
            if t == '|vpiLhs:' and k == ind + 2 and lhskind == '?':
                lhskind = L[j + 1].strip().split(':')[0].lstrip('\\_')
                lb = len(L[j + 1]) - len(L[j + 1].lstrip())
                y = j + 2
                while y < len(L) and (not L[y].strip() or
                                      len(L[y]) - len(L[y].lstrip()) > lb):
                    if L[y].strip() == '|vpiActual:' and \
                       len(L[y]) - len(L[y].lstrip()) == lb + 2:
                        act = True
                        break
                    y += 1
            if t == '|vpiRhs:' and k == ind + 2 and rhs_at is None:
                rhs_at = j + 1
                rk, rf = _obj(L, j + 1)
                # the WHOLE Rhs subtree, for the unsized detector
                rb = len(L[j + 1]) - len(L[j + 1].lstrip())
                y = j + 1
                while y < len(L) and (not L[y].strip() or
                                      len(L[y]) - len(L[y].lstrip()) >= rb):
                    if y > j + 1 and len(L[y]) - len(L[y].lstrip()) < rb:
                        break
                    if L[y].strip() == '|vpiSize:-1':
                        uns = True
                    y += 1
            j += 1
        if owner != 'gen_scope':
            continue
        f1f = f1o = f2 = False
        if rk == 'constant':
            try:
                sz = int(rf.get('vpiSize', '-1'))
            except ValueError:
                sz = -1
            if sz != -1:
                if rf.get('vpiDecompile', '') in FILLDEC:
                    f1f = True
                elif _allones(rf.get('VAL', ''), sz):
                    f1o = True
        if lhskind == 'ref_obj' and act and uns:
            f2 = True
        if f1f or f1o or f2:
            hits.append((m.group(1), m.group(2), lhskind, rk,
                         int(f1f), int(f1o), int(f2)))
    return hits


tot = [0, 0, 0]
for p in sys.argv[1:]:
    h = scan(p)
    for r in h:
        print('%s line=%s:%s lhs=%s rhs=%s F1F=%d F1O=%d F2=%d'
              % (p, r[0], r[1], r[2], r[3], r[4], r[5], r[6]))
        for z in range(3):
            tot[z] += r[4 + z]
print('TOTAL F1F=%d F1O=%d F2=%d' % tuple(tot))
