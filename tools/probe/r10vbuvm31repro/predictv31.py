# vbuvm31 verifier — MOVER PREDICTION for the VERIFIED binary, from the
# PRISTINE + GOLDEN corpus censuses only (no patched database is read).
# Two producers, both enumerated:
#   A  the law:  golden's unsized array_var (at 2/3/4) carries an operation and
#      OUR array_var or its vpiReg element does not.
#   B  the gate: OUR pristine unsized array_var already carries an operation
#      one of whose DIRECT constant operands has a WRITTEN width (a base tick
#      in the decompile) that the old unconditional resize overwrote — the
#      verified binary restores the written width, so the database moves.
import glob, re, sys, collections
d = sys.argv[1]
rows = collections.defaultdict(lambda: {'G': [], 'O': []})
for f in glob.glob(d + '/[go].*.txt'):
    for line in open(f):
        p = line.rstrip('\n').split('\t')
        if len(p) < 10: continue
        side, rel = p[0].split(':', 1)
        rows[rel][side].append(p)
def k(p): return (p[2], p[3], p[4], p[5])
CONST = re.compile(r"C\(ct=(\d+),sz=(-?\d+),dc=([^,)]*)\)")
def toplevel_consts(expr):
    # DIRECT operands of the outermost OPnn( ... ) only
    m = re.match(r'expr=OP\d+\((.*)\)$', expr)
    if not m: return []
    body = m.group(1); out = []; depth = 0; cur = ''
    for ch in body:
        if ch == '(' : depth += 1
        if ch == ')' : depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur); cur = ''
        else:
            cur += ch
    out.append(cur)
    res = []
    for o in out:
        mm = CONST.fullmatch(o.strip())
        if mm: res.append((int(mm.group(1)), int(mm.group(2)), mm.group(3)))
    return res
A = []; B = []
for rel, v in sorted(rows.items()):
    g = collections.defaultdict(list); o = collections.defaultdict(list)
    for p in v['G']: g[k(p)].append(p)
    for p in v['O']: o[k(p)].append(p)
    for key, ps in g.items():
        if key[2] not in ('at=2', 'at=3', 'at=4'): continue
        if not any(p[7] != 'expr=-' for p in ps): continue
        mine = o.get(key, [])
        if not mine or any(p[7] == 'expr=-' for p in mine):
            A.append((rel, key)); continue
        # element carrier: same loc, at=0, empty name
        ek = (key[0], None, 'at=0', '')
        for kk, pp in o.items():
            if kk[0] == key[0] and kk[2] == 'at=0' and kk[3] == '' and \
               any(x[7] == 'expr=-' for x in pp):
                A.append((rel, key)); break
    for key, ps in o.items():
        if key[2] not in ('at=2', 'at=3', 'at=4'): continue
        for p in ps:
            for ct, sz, dc in toplevel_consts(p[7]):
                m = re.match(r"^(\d+)'", dc)
                if m and int(m.group(1)) != sz:
                    B.append((rel, key, dc, sz))
print("A (law) test-modes:", len(set(r for r, _ in A)))
for r in sorted(set(r for r, _ in A)): print("   A", r)
print("B (resize gate) test-modes:", len(set(r for r, _, _, _ in B)))
for r, key, dc, sz in sorted(set(B)): print("   B", r, key, dc, "size", sz)
