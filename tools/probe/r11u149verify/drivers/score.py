#!/usr/bin/env python3
# score.py [cw dirs...]: per case x mode, the law's own switch (OWN) and both landings off (OFF) against law on (ON),
# judged on uhdm-cmp line count, the order-blind dump distance to golden, and the strict records (worse.py's rule:
# a record that the reference walk matched before its own structural divergence and that differs under ON = NEW).
import sys, os, re, glob
STRUCT = ('type', 'depth', 'count', 'name')
def recs(f):
    if not os.path.exists(f): return None, False, 'missing'
    t = open(f).read(); lines = t.split('\n'); d = {}
    for i, ln in enumerate(lines):
        m = re.match(r'#(\d+) (\w+)', ln)
        if m:
            a = lines[i+1].strip() if i+1 < len(lines) else ''; b = lines[i+2].strip() if i+2 < len(lines) else ''
            d[int(m.group(1))] = (m.group(2), a, b)
    last = [l for l in lines if l.strip()][-1] if t.strip() else ''
    return d, '(walk diverged)' in t, last
def info(w, tag):
    r = {}
    txt = open(f'{w}/{tag}.line').read() if os.path.exists(f'{w}/{tag}.line') else ''
    return r
def judge(ref, on):
    dr, vr, lr = ref; dn, vn, ln = on
    if lr.startswith('STRICT_EQUAL') and ln.startswith('STRICT_EQUAL'): return 'EQUAL-BOTH'
    if ln.startswith('STRICT_EQUAL'): return 'CONVERT'
    if lr.startswith('STRICT_EQUAL'): return 'BREAK(equal->NE)'
    if 'NOT_EQUAL' in lr and 'stage1' in lr or 'NOT_EQUAL' in ln and 'stage1' in ln: return 'STAGE1'
    pdiv = min([i for i, (f, _, _) in dr.items() if f in STRUCT], default=10**12) if vr else 10**12
    new = [i for i in dn if i < pdiv and i not in dr]
    chg = [i for i in dn if i < pdiv and i in dr and dn[i][2] != dr[i][2]]
    if new: return f'NEW{new[:3]}'
    if set(dn) <= set(dr): return 'IMPROVE' if len(dn) < len(dr) or chg else 'SAME-RECS'
    return f'UNMASK(refdiv={pdiv if pdiv < 10**12 else None})'
G = {}
for f in glob.glob('/tmp/r11u149_grid/*__*.txt'):
    for ln in open(f):
        m = re.match(r'(\S+) (plain|elab) (ON|OFF|OWN) slrc=(\S+) rc=(\S+) cmp=(\d+) ob=(\d+) md5=(\S*) \| (.*)', ln.strip())
        if m:
            k = m.group(1).replace('/', '__') + '__' + m.group(2)
            v = m.group(9)
            v = 'EQ' if v.startswith('STRICT_EQUAL') else ('NE:' + v.split()[1] if v.startswith('STRICT_NOTEQUAL') else ('S1' if 'stage1' in v else v[:20]))
            G.setdefault(k, {})[m.group(3)] = f"{v}/c{m.group(6)}/o{m.group(7)}" + ('' if m.group(5) == '0' else f'/rc{m.group(5)}')
rows = []
for w in sorted(sys.argv[1:] or glob.glob('/tmp/r11u149_cw/*__*__*')):
    if not os.path.exists(w + '/ON.strict'): continue
    name = os.path.basename(w)
    def md5(t):
        try:
            import hashlib; return hashlib.md5(open(f'{w}/{t}.uhdm', 'rb').read()).hexdigest()[:8]
        except Exception: return '-'
    R = {t: recs(f'{w}/{t}.strict') for t in ('ON', 'OWN', 'OFF')}
    cmpn = {}
    obd = {}
    for t in ('ON', 'OWN', 'OFF'):
        import subprocess
        cmpn[t] = None
    m = {t: md5(t) for t in ('ON', 'OWN', 'OFF')}
    v_own = 'same-bytes' if m['ON'] == m['OWN'] else judge(R['OWN'], R['ON'])
    v_off = 'same-bytes' if m['ON'] == m['OFF'] else judge(R['OFF'], R['ON'])
    short = lambda x: x[2].replace('STRICT_NOTEQUAL ', 'NE:').replace('STRICT_EQUAL ', 'EQ:').replace(' objects', '').replace('NOT_EQUAL stage1', 'stage1')
    g = G.get(name, {})
    print(f"{name}\t{g.get('OFF')}\t{g.get('OWN')}\t{g.get('ON')}\t{v_own}\t{v_off}")
