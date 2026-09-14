# r11u19 A-PRIORI MOVER PREDICTION — reads PRISTINE databases ONLY.
#
# A database with no flagged cell cannot move under
# § genCaPackedPatternFold19.  The scan is a DELIBERATE SUPERSET: it flags
# every ELABORATED gen-scope `cont_assign` whose Rhs is a `vpiOpType:75`
# operation and whose Lhs is a whole `ref_obj`.  It cannot see the TARGET
# TYPESPEC KIND (logic vs bit/int/enum/struct), it cannot see a nested pattern
# operand, and it cannot see whether our emitter's `tryFoldConst` succeeds, so
# it over-flags by design.  The requirement it answers is CONTAINMENT.
#
# LAW 2 (§ caTernFillArmKeepsEncoding19): every `cont_assign` in the dump whose
# Rhs is a `vpiOpType:32` (vpiConditionOp) operation carrying, anywhere in its
# operand subtree, a constant with `vpiSize:-1` — an unbased-unsized fill
# literal.  Both views are scanned; the DEFINITION row is the stable one (no
# law touches it) and the elaborated row only widens the superset.  It cannot evaluate the condition, it cannot apply the operand
# gate and it cannot see the Lhs shape, so it over-flags by design.
#
# usage: pred19.py <dump> [<dump> ...]
import re, sys

def _read(path):
    if path == '-':
        return sys.stdin.read().split('\n')
    return open(path, errors='replace').read().split('\n')


def scan(path, L=None):
    # NO SECTIONING.  `|uhdmallModules:` and `|uhdmtopModules:` are REPEATED
    # keys, once per module, not two contiguous sections — a scan that cut at
    # the "next |uhdm line" covered almost nothing on a real design (measured:
    # Earlgrey_0_1's dump has 149916 lines before the first `|uhdmallModules:`
    # and hundreds of them after).  The whole dump is walked instead, which
    # only widens the superset.  `owner == gen_scope` still selects the
    # ELABORATED rows on its own: a definition-listing generate block owns its
    # cont_assigns through a `named_begin`.
    L = list(L) if L is not None else _read(path)
    hits = []
    for i, ln in enumerate(L):
        m = re.search(r'\\_cont_assign: , (?:file:\S+, )?line:(\d+):(\d+)', ln)
        if not m:
            continue
        if i and L[i - 1].strip() == '|vpiParent:':
            continue
        ind = len(ln) - len(ln.lstrip())
        owner, lhs, act, op75, rhsref = '?', '?', '<none>', False, False
        j = i + 1
        while j < len(L):
            s = L[j]
            k = len(s) - len(s.lstrip())
            if k <= ind:
                break
            t = s.strip()
            if t == '|vpiParent:' and owner == '?':
                owner = L[j + 1].strip().split(':')[0].lstrip('\\_')
            if t == '|vpiRhs:':
                a = L[j + 1]
                if a.strip().startswith('\\_operation:'):
                    ri = len(a) - len(a.lstrip())
                    q = j + 2
                    while q < len(L):
                        s2 = L[q]
                        k2 = len(s2) - len(s2.lstrip())
                        if k2 <= ri:
                            break
                        if k2 == ri + 2 and s2.strip() == '|vpiOpType:75':
                            op75 = True
                        q += 1
            if t == '|vpiLhs:':
                a = L[j + 1]
                if a.strip().startswith('\\_ref_obj:'):
                    rhsref = True
                    mm = re.search(r'\((.*?)\)', a)
                    lhs = mm.group(1) if mm else '?'
                    ri = len(a) - len(a.lstrip())
                    q = j + 2
                    while q < len(L):
                        s2 = L[q]
                        k2 = len(s2) - len(s2.lstrip())
                        if k2 <= ri:
                            break
                        if s2.strip() == '|vpiActual:':
                            act = L[q + 1].strip().split(':')[0].lstrip('\\_')
                            break
                        q += 1
            j += 1
        if owner == 'gen_scope' and op75 and rhsref:
            hits.append((m.group(1) + ':' + m.group(2), lhs, act))
    return hits

def scan2(path, L=None):
    """LAW 2: any cont_assign with a ternary Rhs carrying a size -1 constant."""
    L = list(L) if L is not None else _read(path)
    hits = []
    for i, ln in enumerate(L):
        m = re.search(r'\\_cont_assign: , (?:file:\S+, )?line:(\d+):(\d+)', ln)
        if not m:
            continue
        if i and L[i - 1].strip() == '|vpiParent:':
            continue
        ind = len(ln) - len(ln.lstrip())
        j = i + 1
        cond32, fill = False, False
        while j < len(L):
            s2 = L[j]
            k = len(s2) - len(s2.lstrip())
            if k <= ind:
                break
            t = s2.strip()
            if t == '|vpiOpType:32':
                cond32 = True
            if t == '|vpiSize:-1':
                fill = True
            j += 1
        if cond32 and fill:
            hits.append((m.group(1) + ':' + m.group(2), '<tern>', 'fill'))
    return hits

tot1 = tot2 = 0
for p in sys.argv[1:]:
    _L = _read(p)
    h1, h2 = scan(p, _L), scan2(p, _L)
    tot1 += len(h1)
    tot2 += len(h2)
    if h1 or h2:
        print(f"{p}: LAW1 {len(h1)} cell(s)  LAW2 {len(h2)} cell(s)")
        for loc, lhs, act in h1:
            print(f"    LAW1 {loc:>10} lhs={lhs} actual={act}")
        for loc, lhs, act in h2:
            print(f"    LAW2 {loc:>10} ternary-with-fill")
print("FLAGGED CELLS: LAW1", tot1, "LAW2", tot2,
      "over", len(sys.argv) - 1, "database(s)")
