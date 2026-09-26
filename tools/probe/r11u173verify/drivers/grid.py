#!/usr/bin/env python3
"""grid.py [--el] [--pairs] <casedir>... : score every case law-on against law-off (r11u173: passes 164 and 167).

The first line of a case names its laws (`// § a § b`).  States on the frozen HEAD binary ($LAW): ON (no switch),
OFF_<law> (the law's own switches; a verifier refinement `...v` is also scored against its parent's switch, which is
pristine for that site), OFF2 for every pair of named laws (--pairs, or when the case dir is under cx/), OFFL<n> for
each landing a named law belongs to, ALLOFF (both landings off: R11U161_OFF R11U164_OFF R11U167_OFF), ALLOFF170
(ALLOFF + R11V170_OFF, r11u170's refinements that landed between the two), and PRE ($PRE, the build of d8cfd83a, the
commit before pass 164; ALLOFF170 must equal it byte for byte).  Per state: uhdm-cmp rc/lines, the strict verdict and the strict
records (index, field, golden joined, ours joined).  Per law:
  UNFIRED    ON and OFF write the same bytes
  TOWARD     OFF's records that ON lost, none new
  AWAY       ON has a record OFF did not, both walks aligned (a BREAK candidate: inspect)
  MIXED      both, walks aligned (inspect)
  UNMASK     ON has new records but OFF's walk diverged earlier than ON's (the new records sit past OFF's divergence)
  BYTES-ONLY bytes move, the record multiset does not
  STAGE1-x   either state is stage 1: the order-blind dump distance to golden decides (CLOSER / SAME / AWAY)
Fail-closed on $FENCED."""
import os, re, subprocess, sys, itertools, collections, hashlib
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('grid.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
from laws import SW, PARENT, LANDING, ALLOFF, landing_of
DUMP = os.environ['UHDM_DUMP']; LAW = os.environ['LAW']; PRE = os.environ.get('PRE', '')
GW = os.environ.get('GW', '/tmp/r11u173_g')

def env_of(law): return [s + '=1' for s in SW[law]]

def run(case, tag, envs, el, binary=None):
    env = dict(os.environ); env['EL'] = '1' if el else '0'
    return subprocess.run([f'{D}/case.sh', case, tag, binary or LAW] + envs, capture_output=True, text=True, env=env).stdout.strip()

def wdir(case, el):
    return f'{GW}/' + case.split('/r11u173verify/cases/')[1] + ('_el' if el else '')

def recs(w, tag):
    """(Counter of (field, A, B), list of (idx, field), last line, diverged index or None)"""
    p = f'{w}/{tag}.strict'
    if not os.path.exists(p): return None, [], 'NODB', None
    L = open(p, errors='replace').read().splitlines()
    last = L[-1] if L else ''
    if 'stage1' in last or not L: return None, [], 'stage1', None
    s = collections.Counter(); idx = []
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L):
            s[(m.group(2), L[i+1].strip(), L[i+2].strip())] += 1; idx.append((int(m.group(1)), m.group(2)))
    div = idx[-1][0] if any('walk diverged' in l for l in L) and idx else None
    if div is None and any(l.startswith('objects ') for l in L) and not idx: div = -1
    return s, idx, last, div

def dump(f):
    t = subprocess.run([DUMP, f], capture_output=True, text=True, errors='replace').stdout
    return collections.Counter(re.sub(r'id:\d+', '', re.sub(r'/[^ ,:()]*/', '', l)).strip() for l in t.splitlines()
                               if 'Restored design' not in l)

def dist(a, b): return sum(((a - b) + (b - a)).values())

def md5(f): return hashlib.md5(open(f, 'rb').read()).hexdigest()[:8] if os.path.exists(f) else '-'

def score(w, on, off, g):
    fon, foff = f'{w}/{on}.uhdm', f'{w}/{off}.uhdm'
    if not (os.path.exists(fon) and os.path.exists(foff)):
        return ('NODB' if not os.path.exists(fon) and not os.path.exists(foff) else 'DB-PRESENCE-DIFFERS'), ''
    if md5(fon) == md5(foff): return 'UNFIRED', ''
    ra, ia, la, da = recs(w, on); rb, ib, lb, db = recs(w, off)
    if ra is not None and rb is not None:
        new = ra - rb; gone = rb - ra
        if not new: v = 'TOWARD' if gone else 'BYTES-ONLY'
        elif db is not None and (da is None or da > db): v = 'UNMASK'
        else: v = 'AWAY' if not gone else 'MIXED'
        det = f'new={sum(new.values())} gone={sum(gone.values())} off:{lb.replace(" ", "_")}{"(div@%d)" % db if db is not None else ""} on:{la.replace(" ", "_")}{"(div@%d)" % da if da is not None else ""}'
        if new and v != 'UNMASK': det += ' | first new: ' + ' / '.join(sorted(new)[0])[:400]
        return v, det
    dg, dn, df = dump(g), dump(fon), dump(foff)
    a, b = dist(dg, df), dist(dg, dn)
    nb = (dn - dg) - (df - dg)
    v = 'STAGE1-' + ('CLOSER' if b < a else 'SAME' if a == b else 'AWAY')
    det = f'off:{lb} on:{la} dump off={a} on={b} newbad={sum(nb.values())}'
    if sum(nb.values()) and v == 'STAGE1-AWAY': det += ' | +' + ' | +'.join(list(nb)[:3])
    return v, det

def main():
    args = sys.argv[1:]; el = False; pairs = False
    while args and args[0].startswith('--'):
        if args[0] == '--el': el = True
        if args[0] == '--pairs': pairs = True
        args = args[1:]
    for case in args:
        case = os.path.abspath(case)
        if any(re.search(rf'\b{re.escape(n)}\b', case) for n in FENCED): print('FENCED-SKIP', case); continue
        named = re.findall(r'§ (\w+)', open(f'{case}/dut.sv').readline())
        laws = list(named)
        for l in named:
            if l in PARENT and PARENT[l] not in laws: laws.append(PARENT[l])
        w = wdir(case, el); rel = w.split(GW + '/')[1]
        lines = [run(case, 'on', [], el)]
        states = []
        for l in laws:
            lines.append(run(case, 'off_' + l, env_of(l), el)); states.append(('off_' + l, l))
        lands = sorted({landing_of(l) for l in laws})
        for n in lands:
            lines.append(run(case, f'offL{n}', [s + '=1' for s in LANDING[n]], el)); states.append((f'offL{n}', f'LANDING{n}'))
        if (pairs or '/cx/' in case) and len(named) > 1:
            for a, b in itertools.combinations(named, 2):
                t = f'off2_{a}_{b}'; lines.append(run(case, t, env_of(a) + env_of(b), el)); states.append((t, f'PAIR:{a}+{b}'))
        lines.append(run(case, 'alloff', [s + '=1' for s in ALLOFF], el))
        lines.append(run(case, 'alloff170', [s + '=1' for s in ALLOFF + ['R11V170_OFF']], el))
        if PRE: lines.append(run(case, 'pre', [], el, PRE))
        for l in lines: print('  ' + l)
        g = None
        if os.path.isdir(w):
            for x in os.listdir(w):
                if x.startswith('gold_') and os.path.exists(f'{w}/{x}/golden.uhdm'): g = f'{w}/{x}/golden.uhdm'
        if not g: print('RESULT', rel, 'NOGOLD', flush=True); continue
        for t, l in states:
            v, det = score(w, 'on', t, g)
            print('RESULT', rel, l, v, det, flush=True)
        v, det = score(w, 'on', 'alloff', g)
        print('RESULT', rel, 'ALLOFF', v, det, flush=True)
        if PRE:
            print('RESULT', rel, 'ALLOFF==PRE', 'YES' if md5(f'{w}/alloff170.uhdm') == md5(f'{w}/pre.uhdm') else 'NO', flush=True)

main()
