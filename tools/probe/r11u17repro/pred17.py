#!/usr/bin/env python3
"""r11u17 A-PRIORI mover predictor, computed from PRISTINE databases only.

Two laws, two scans, both read straight off a pristine `uhdm-dump`:

  LAW 1  § genCaLhsArrayNetNeverBinds17 -- a cont_assign owned by a gen_scope
         whose Lhs ref_obj's vpiActual is an `array_net`.  The law removes that
         actual, so a database with no such cell cannot move under it.

  LAW 2  § genCaBoundLhsOperationRhsUnbindsRhs17 -- a cont_assign owned by a
         gen_scope whose Lhs ref_obj HAS an actual (anything but an array_net)
         and whose Rhs is an `operation`; every ref_obj in that Rhs subtree
         that carries a vpiActual is a cell the law removes.

Both are deliberate SUPERSETS of what the emitter can reach (the dump does not
say which Rhs kinds our emitter classifies as an operation, and it cannot see
a suppression another law already applies).  The requirement they answer is
CONTAINMENT: every measured mover must be named here.

usage: pred17.py <workdir-or-dump-dir> [...]      (finds *.uhdm underneath)
       pred17.py --dump <file.dump> [...]         (scores an existing dump)
"""
import os, re, sys, subprocess, concurrent.futures

DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
NODE = re.compile(r'\\_(\w+): ?\(?([^)]*)\)?')


def parse(text):
    """[(indent, kind, name, lineno)] for every '\\_kind:' node, in file order."""
    out = []
    for i, ln in enumerate(text.split('\n')):
        s = ln.lstrip()
        if not s.startswith('\\_'):
            continue
        m = NODE.match(s)
        if m:
            out.append((len(ln) - len(s), m.group(1), m.group(2), i))
    return out


def scan(text):
    L = text.split('\n')
    nodes = parse(text)
    # index: line number -> position in `nodes`
    hits1, hits2 = [], []

    def attr_child(lineno, indent, attr):
        """The node that follows `|attr:` inside the node starting at lineno."""
        j = lineno + 1
        while j < len(L):
            t = L[j]
            k = len(t) - len(t.lstrip())
            if k <= indent and t.lstrip().startswith('\\_'):
                break
            if k <= indent and not t.lstrip().startswith('|'):
                break
            if t.strip() == attr:
                n = L[j + 1]
                kn = len(n) - len(n.lstrip())
                m = NODE.match(n.lstrip())
                if m:
                    return (kn, m.group(1), m.group(2), j + 1)
                return None
            j += 1
        return None

    stack = []
    for idx, (ind, kind, name, lineno) in enumerate(nodes):
        while stack and stack[-1][0] >= ind:
            stack.pop()
        stack.append((ind, kind, name, lineno))
        if kind != 'cont_assign':
            continue
        # nearest enclosing scope must be a gen_scope
        owner = None
        for (o_i, o_k, o_n, o_l) in reversed(stack[:-1]):
            if o_k in ('gen_scope', 'gen_scope_array'):
                owner = 'gen'
                break
            if o_k in ('module_inst', 'interface_inst', 'package', 'program'):
                break
        if owner != 'gen':
            continue
        lhs = attr_child(lineno, ind, '|vpiLhs:')
        rhs = attr_child(lineno, ind, '|vpiRhs:')
        if not lhs or lhs[1] != 'ref_obj':
            continue
        lact = attr_child(lhs[3], lhs[0], '|vpiActual:')
        if lact and lact[1] == 'array_net':
            hits1.append(('LAW1', lhs[2], lact[1]))
            continue
        if not lact or not rhs or rhs[1] != 'operation':
            continue
        # every bound ref_obj in the Rhs subtree
        base = rhs[0]
        for (i2, k2, n2, l2) in nodes:
            if l2 <= rhs[3]:
                continue
            if i2 <= base and l2 != rhs[3]:
                break
            if k2 != 'ref_obj':
                continue
            a2 = attr_child(l2, i2, '|vpiActual:')
            if a2:
                hits2.append(('LAW2', lhs[2], n2, a2[1]))
    return hits1, hits2


def one(path, is_dump):
    try:
        if is_dump:
            txt = open(path, errors='replace').read()
        else:
            txt = subprocess.run([DUMP, path], capture_output=True, text=True,
                                 timeout=1800).stdout
    except Exception as e:
        return (path, None, None, str(e))
    h1, h2 = scan(txt)
    return (path, h1, h2, None)


def main():
    args = sys.argv[1:]
    is_dump = False
    if args and args[0] == '--dump':
        is_dump = True
        dbs = args[1:]
    else:
        dbs = []
        for wd in args:
            if os.path.isfile(wd):
                dbs.append(wd)
                continue
            for root, _, files in os.walk(wd):
                for f in files:
                    if f.endswith('.uhdm'):
                        dbs.append(os.path.join(root, f))
    dbs.sort()
    print(f"# databases: {len(dbs)}", file=sys.stderr)
    res = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
        for p, h1, h2, err in ex.map(lambda d: one(d, is_dump), dbs):
            if err:
                print(f"ERR {p} {err}", file=sys.stderr)
                continue
            if h1 or h2:
                res[p] = (h1, h2)
    n1 = n2 = 0
    for p in sorted(res):
        h1, h2 = res[p]
        n1 += len(h1)
        n2 += len(h2)
        print(f"{len(h1)}\t{len(h2)}\t{p}")
        for h in h1[:4]:
            print(f"\t\tLAW1 lhs={h[1]} actual={h[2]}")
        for h in h2[:6]:
            print(f"\t\tLAW2 lhs={h[1]} ref={h[2]} actual={h[3]}")
    print(f"# flagged databases: {len(res)}  LAW1 cells: {n1}  LAW2 cells: {n2}",
          file=sys.stderr)


main()
