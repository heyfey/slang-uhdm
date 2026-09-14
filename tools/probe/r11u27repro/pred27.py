#!/usr/bin/env python3
# r11u27 CENSUS / A-PRIORI MOVER PREDICTION — reads PRISTINE databases ONLY.
#
# FACE 3 = the NON-TERNARY cont-assign fold.  Two SEPARABLE halves, both a
# deliberate SUPERSET, both counted on the PRISTINE database where a cell that
# is absent cannot move:
#
#   FB  THE BOUND HALF (the risk set).  An ELABORATED cont_assign whose Lhs is
#       a whole `ref_obj` and whose Rhs is ALREADY a `constant` — a cell this
#       emitter already folds, so the law can only RE-ENCODE it.  Split by the
#       encoding we currently carry, because the law can only turn `UINT:`(9)
#       into `INT:`(7) or `BIN:`(3):
#         FB9  our Rhs constant is vpiConstType 9 (UINT)  <- the movable set
#         FB7  already 7 (INT)      FB3  already 3 (BIN)      FBX  anything else
#       It cannot see the operand shapes that decide golden's branch, so FB9
#       is a gross superset of the cells the law would actually flip.
#
#   FU  THE UNBOUND HALF.  An ELABORATED `gen_scope` cont_assign whose Lhs is a
#       whole `ref_obj` and whose Rhs is still an `operation` — a cell this
#       emitter does NOT fold and the law could install a constant into.
#       It cannot see whether the operands are constant, so it over-flags.
#
# NO SECTIONING (r11u19's bug: the uhdm keys repeat); the whole dump is walked.
# usage: pred27.py <dump> [...]      ('-' reads stdin)
import re, sys


def _read(path):
    if path == '-':
        return sys.stdin.read().split('\n')
    return open(path, errors='replace').read().split('\n')


def _obj(L, k):
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
            mm = re.match(r'^\|(vpiSize|vpiDecompile|vpiConstType|vpiOpType):(.*)$', s)
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
        rk, rf = '?', {}
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
            if t == '|vpiRhs:' and k == ind + 2 and rhs_at is None:
                rhs_at = j + 1
                rk, rf = _obj(L, j + 1)
            j += 1
        # ELABORATED rows only: a def-view generate block owns its cont_assigns
        # through a `named_begin`, an elaborated one through `gen_scope`; a
        # module-scope cell's owner is the module_inst either way, so the
        # elaborated/def split for FB is made by the caller's dump section.
        if lhskind != 'ref_obj':
            continue
        fb9 = fb7 = fb3 = fbx = fu = 0
        if rk == 'constant':
            ct = rf.get('vpiConstType', '')
            if ct == '9':
                fb9 = 1
            elif ct == '7':
                fb7 = 1
            elif ct == '3':
                fb3 = 1
            else:
                fbx = 1
        elif rk == 'operation' and owner == 'gen_scope':
            fu = 1
        if fb9 or fb7 or fb3 or fbx or fu:
            hits.append((m.group(1), m.group(2), owner, rk,
                         rf.get('vpiConstType', rf.get('vpiOpType', '')),
                         fb9, fb7, fb3, fbx, fu))
    return hits


tot = [0, 0, 0, 0, 0]
for p in sys.argv[1:]:
    h = scan(p)
    for r in h:
        print('%s line=%s:%s owner=%s rhs=%s t=%s FB9=%d FB7=%d FB3=%d FBX=%d FU=%d'
              % ((p,) + r))
        for z in range(5):
            tot[z] += r[5 + z]
print('TOTAL FB9=%d FB7=%d FB3=%d FBX=%d FU=%d' % tuple(tot))
