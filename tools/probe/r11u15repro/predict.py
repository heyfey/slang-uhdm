#!/usr/bin/env python3
"""r11u15 A-PRIORI mover predictor, computed from PRISTINE databases only.

The law (§ genCaDrivenOpenerIsGenLocalOnly) narrows the "driven in this
gen-scope" opener of the gen-scope cont_assign RHS suppression to symbols
DECLARED IN A GENERATE SCOPE.  The only cells it can move are, exactly:

    a ref_obj that is (or is inside) the Rhs of a cont_assign owned by a
    gen_scope, whose vpiActual is an object whose OWNER is a module_inst /
    interface_inst -- i.e. a MODULE-BODY signal bound from inside a generate
    scope's continuous assignment.

Those cells exist only in the ELABORATED listing and are read straight off the
PRISTINE dump, before the patched binary is run anywhere.  A database with zero
such cells cannot move.

usage: predict.py <workdir> [<workdir>...]
"""
import os, re, sys, subprocess, concurrent.futures

DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')

def scan(dumptext):
    """Return the list of (owner_scope_fullname, ref_name) cells at risk."""
    L = dumptext.split('\n')
    hits = []
    # stack of (indent, kind, name)
    stack = []
    for i, ln in enumerate(L):
        s = ln.lstrip()
        ind = len(ln) - len(s)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        m = re.match(r'\\_(\w+): ?\(?(.*?)\)?,? ?(?:line|file|id):', s)
        if m:
            stack.append((ind, m.group(1), m.group(2)))
        if not s.startswith('|vpiRhs:'):
            continue
        # the Rhs subtree of a cont_assign whose nearest scope owner is gen_scope
        owner = None
        for (o_i, o_k, o_n) in reversed(stack):
            if o_k == 'cont_assign':
                owner = 'ca'
            elif o_k in ('gen_scope', 'gen_scope_array'):
                owner = 'gen' if owner == 'ca' else None
                break
            elif o_k in ('module_inst', 'interface_inst', 'package'):
                break
        if owner != 'gen':
            continue
        # walk the Rhs subtree, collect ref_obj -> vpiActual owner
        j = i + 1
        base = ind
        while j < len(L):
            t = L[j]; k = len(t) - len(t.lstrip())
            if k <= base and t.strip().startswith('|vpi'):
                break
            if k < base:
                break
            mm = re.search(r'\\_ref_obj: \((.*?)\)', t)
            if mm:
                # find its vpiActual
                rind = k
                jj = j + 1
                while jj < len(L):
                    u = L[jj]; ku = len(u) - len(u.lstrip())
                    if ku <= rind: break
                    if u.strip() == '|vpiActual:':
                        act = L[jj+1].strip()
                        # the actual's OWNER is read from its fullname: a
                        # module-body signal's fullname has no gen-scope hop
                        ma = re.search(r'\\_(\w+): ?\(?([\w@.:\[\]$]*)\)?', act)
                        if ma and ma.group(1) not in ('constant',):
                            full = ma.group(2)
                            refname = mm.group(1)
                            # gen-local?  the actual's fullname must be a
                            # prefix-extension of the gen scope path.  The
                            # REF's own fullname carries the gen path; strip
                            # the leaf and compare.
                            genpath = refname.rsplit('.', 1)[0]
                            if not full.startswith(genpath + '.'):
                                hits.append((genpath, refname, ma.group(1), full))
                        break
                    jj += 1
            j += 1
    return hits

def one(path):
    try:
        out = subprocess.run([DUMP, path], capture_output=True, text=True,
                             timeout=900).stdout
    except Exception as e:
        return (path, None, str(e))
    return (path, scan(out), None)

def main():
    dbs = []
    for wd in sys.argv[1:]:
        for root, _, files in os.walk(wd):
            for f in files:
                if f.endswith('.uhdm'):
                    dbs.append(os.path.join(root, f))
    dbs.sort()
    print(f"# databases: {len(dbs)}", file=sys.stderr)
    res = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
        for p, h, err in ex.map(one, dbs):
            if err:
                print(f"ERR {p} {err}", file=sys.stderr); continue
            if h:
                res[p] = h
    for p in sorted(res):
        rel = p
        print(f"{len(res[p])}\t{rel}")
        for g, r, k, f in res[p][:6]:
            print(f"\t\t{r} -> {k} {f}")

main()
