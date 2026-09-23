#!/usr/bin/env python3
"""r11u104 A-PRIORI MOVER CENSUS for § readerWidthIsTheSecondAdjust104 — keyed
on the DATABASES, golden first.

For every sweep row that has BOTH databases, both are dumped and every
`cont_assign` cell is read by NET NAME (nda104.read: every depth, every view,
the multiset kept).  A cell is in REACH when our right-hand side is a constant, golden has a cell
under the same key, and the initializer text is a NAME; it is a CANDIDATE when
  * OUR right-hand side is a constant,
  * the initializer TEXT of that net in the row's own test tree is a bare or
    package-qualified NAME (the only shape the fold site's hand-off reaches),
  * and GOLDEN writes a constant there whose SIZE differs from ours, or whose
    value differs where ours is `UINT:` (the two faces the law writes).
A NOFOLD cell (golden writes no constant) with a NAME initializer and a
constant on our side is reported apart: the law may move its bytes, never its
compare.  This is a strict SUPERSET of the gate (a module parameter's NAME is
counted, the pkg-param restriction is not checked), reported so.

usage: census104.py <sweep workdir> [...]     one line per candidate row
       census104.py --gg <sweep workdir>      the golden-vs-golden calibration:
                                              golden read twice, 0 candidates
       census104.py --pair <sv> <g.dump> <o.dump>   one arm (the controls)
"""
import hashlib, os, re, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from nda104 import read
DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
SCR = os.environ.get('CEN104_SCRATCH', '/tmp/r11u104_cen')
NAME = re.compile(r'^\(*\s*(?:\w+\s*::\s*)?[A-Za-z_]\w*\s*\)*$')

def rhs_texts(files, net):
    pat = re.compile(r'(?<![\w.])' + re.escape(net) + r'\s*=\s*([^;,]+)[;,]')
    out = set()
    for f in files:
        try:
            t = open(f, errors='replace').read()
        except OSError:
            continue
        t = re.sub(r'//[^\n]*', '', t)
        t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
        for m in pat.finditer(t):
            out.add(' '.join(m.group(1).split()))
    return out

def cells(g, o, files):
    G, O = read(g), read(o)
    res = []
    for k, oc in O.items():
        if oc.get('kind') != 'constant':
            continue
        net = k.split('@')[0].split('#')[0]
        tx = rhs_texts(files, net)
        if not tx or not any(NAME.match(x) for x in tx):
            continue
        gc = G.get(k)
        if gc is None:
            continue
        res.append(('REACH', k, gc, oc))
        if gc.get('kind') != 'constant':
            res.append(('NOFOLD', k, gc.get('kind'), oc))
            continue
        sz = gc['sz'] != oc['sz']
        val = oc['v'].startswith('UINT:') and gc['v'] != oc['v']
        if sz or val:
            res.append(('SIZE' if sz else 'VALUE', k, gc, oc))
    return res

def dump(u, out):
    if not os.path.exists(out) or os.path.getsize(out) == 0:
        try:
            r = subprocess.run([DUMP, u], capture_output=True, timeout=600)
            open(out, 'wb').write(r.stdout)
        except subprocess.TimeoutExpired:
            open(out, 'wb').write(b'')
    return out

def rowmap():
    sys.dont_write_bytecode = True
    sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'scripts'))
    import verify_golden as V
    m = {}
    for d in (V.discover_uhdm2rtlil(None), V.discover_surelog(None)):
        for name, (dp, _parts) in d.items():
            m[name + '-' + hashlib.sha1(dp.encode()).hexdigest()[:8]] = dp
    return m

def srcfiles(dp):
    fs = []
    for r, _d, f in os.walk(dp):
        for x in f:
            if x.endswith(('.sv', '.v', '.svh', '.vh')):
                fs.append(os.path.join(r, x))
    return fs

def golden_of(rowdir):
    c = open(os.path.join(rowdir, 'cmds.txt'), errors='replace').read()
    m = re.search(r'golden cache hit (\S+)\)', c)
    if m and os.path.exists(os.path.join(m.group(1), 'golden.uhdm')):
        return os.path.join(m.group(1), 'golden.uhdm')
    for r, _d, f in os.walk(rowdir):
        for x in f:
            if x.endswith('.uhdm') and x != 'slang.uhdm':
                return os.path.join(r, x)
    return None

def main():
    a = sys.argv[1:]
    if a and a[0] == '--pair':
        for kind, k, gc, oc in [c for c in cells(a[2], a[3], [a[1]]) if c[0] != 'REACH']:
            print(kind, k, gc if isinstance(gc, str) else gc.get('v'), oc['v'], oc['sz'])
        return
    gg = a and a[0] == '--gg'
    if gg:
        a = a[1:]
    M = rowmap()
    tot = {}
    for wd in a:
        for mode in sorted(os.listdir(wd)):
            md = os.path.join(wd, mode)
            if not os.path.isdir(md):
                continue
            for row in sorted(os.listdir(md)):
                rd = os.path.join(md, row)
                su = os.path.join(rd, 'slang.uhdm')
                if not os.path.exists(su) or not os.path.exists(os.path.join(rd, 'cmds.txt')):
                    continue
                gu = golden_of(rd)
                if not gu or row not in M:
                    tot['NOGOLDEN_OR_NOMAP'] = tot.get('NOGOLDEN_OR_NOMAP', 0) + 1
                    continue
                os.makedirs(os.path.join(SCR, mode), exist_ok=True)
                gd = dump(gu, os.path.join(SCR, mode, row + '.g.dump'))
                od = gd if gg else dump(su, os.path.join(SCR, mode, row + '.' +
                                        hashlib.sha1(su.encode()).hexdigest()[:6] + '.o.dump'))
                tot['ROWS'] = tot.get('ROWS', 0) + 1
                cs = cells(gd, od, srcfiles(M[row]))
                if not cs:
                    continue
                kinds = {}
                for kind, *_ in cs:
                    kinds[kind] = kinds.get(kind, 0) + 1
                reach = kinds.pop('REACH', 0)
                tot['REACH'] = tot.get('REACH', 0) + reach
                if reach:
                    tot['REACHROWS'] = tot.get('REACHROWS', 0) + 1
                    print('REACH', mode, row.rsplit('-', 1)[0], reach)
                cs = [c for c in cs if c[0] != 'REACH']
                if not cs:
                    continue
                for kk, v in kinds.items():
                    tot[kk] = tot.get(kk, 0) + v
                tot['CANDROWS'] = tot.get('CANDROWS', 0) + (1 if set(kinds) - {'NOFOLD'} else 0)
                print(mode, row.rsplit('-', 1)[0], ' '.join(f'{k}={v}' for k, v in sorted(kinds.items())),
                      '|', '; '.join(f"{k}:{(gc if isinstance(gc, str) else gc['v']+'/'+gc['sz'])}<-{oc['v']}/{oc['sz']}"
                                    for _kind, k, gc, oc in cs[:4]))
    print('TOTAL', ' '.join(f'{k}={v}' for k, v in sorted(tot.items())))

main()
