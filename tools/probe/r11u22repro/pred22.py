# r11u22 A-PRIORI MOVER PREDICTION — reads PRISTINE databases ONLY.
#
# A database with no flagged cell cannot move under
# § genCaTernaryFoldGenScope22.  The scan is a DELIBERATE SUPERSET: it flags
# every ELABORATED gen-scope `cont_assign` whose Rhs is a `vpiOpType:32`
# (vpiConditionOp) operation and whose Lhs is a whole `ref_obj`.  It cannot
# see whether `bindVariable` finds the target (a gen-LOCAL / interface /
# outer-gen-scope Lhs never folds), it cannot apply the operand gate over the
# untaken arm, it cannot evaluate the condition, and it cannot tell an
# INSTALLABLE arm from one the law declines.  It over-flags by design; the
# requirement it answers is CONTAINMENT — no database outside the flagged set
# can move.
#
# `owner == gen_scope` selects the ELABORATED rows on its own: a
# definition-listing generate block owns its cont_assigns through a
# `named_begin`, and no law of this pass touches the definition view.
#
# NO SECTIONING — `|uhdmallModules:` and `|uhdmtopModules:` are REPEATED keys,
# once per module, not two contiguous sections (r11u19's own bug); the whole
# dump is walked, which only widens the superset.
#
# usage: pred22.py <dump> [<dump> ...]     ('-' reads stdin)
import re, sys

def _read(path):
    if path == '-':
        return sys.stdin.read().split('\n')
    return open(path, errors='replace').read().split('\n')

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
        owner, lhs, op32, lhsref = '?', '?', False, False
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
                        if k2 == ri + 2 and s2.strip() == '|vpiOpType:32':
                            op32 = True
                        q += 1
            if t == '|vpiLhs:':
                a = L[j + 1]
                if a.strip().startswith('\\_ref_obj:'):
                    lhsref = True
                    mm = re.search(r'\((.*?)\)', a)
                    lhs = mm.group(1) if mm else '?'
            j += 1
        if owner == 'gen_scope' and op32 and lhsref:
            hits.append((m.group(1) + ':' + m.group(2), lhs))
    return hits

tot = 0
for p in sys.argv[1:]:
    h = scan(p)
    tot += len(h)
    if h:
        print(f"{p}: LAW {len(h)} cell(s)")
        for loc, lhs in h:
            print(f"    LAW {loc:>10} lhs={lhs}")
print("FLAGGED CELLS: LAW", tot, "over", len(sys.argv) - 1, "database(s)")
