#!/usr/bin/env python3
# grid.py <out.tsv> <casedir>... : every case through golden + the frozen binary with its law ON (no switch),
# OFF (the law's own switch, drivers/laws.txt; a refinement's parent switch), ROFF (a refinement's own switch:
# the implementer's form) and ALLOFF (both landings off: the composition). Per case: rc, uhdm-cmp lines, strict
# verdict, md5 per tag; MOVES (on != off bytes); record check (strict dumps, index-aligned: records the law gets
# wrong that off got right, before either walk diverges); order-blind check (sorted uhdm-dump multiset: lines of
# ON not in golden that OFF did not have = AWAY, and lines OFF had wrong that ON fixed = TOWARD).
import sys, os, subprocess, re, collections
from concurrent.futures import ThreadPoolExecutor
D = os.path.dirname(os.path.abspath(__file__))
BIN = os.environ.get('PRIS', '/tmp/r11u153_bin/pris.bin')
GW = os.environ.get('GW', '/tmp/r11u153_g')
LAWS = {}
for l in open(D + '/laws.txt'):
    p = l.split()
    if p: LAWS[p[0]] = p[1:]
ALLOFF = ['R11U145_OFF=1', 'R11V145_LPOPND_OFF=1', 'R11U146_OFF=1', 'R11U148_OFF=1',
          'R11V146_TFARGDPI_OFF=1', 'R11V146_TFARGALIAS_OFF=1', 'R11V146_TPCALHSIF_OFF=1']
def run(c, tag, env):
    r = subprocess.run([D + '/case.sh', c, BIN, tag] + env, capture_output=True, text=True).stdout.strip()
    return r
def rd(f):
    try: return open(f, errors='replace').read().split('\n')
    except Exception: return None
def mset(f):
    x = rd(f); return collections.Counter(l for l in x if 'Restored design' not in l) if x is not None else None
def one(c):
    c = os.path.abspath(c)
    rel = re.sub(r'.*/r11u153verify/cases/', '', c)
    first = open(c + '/dut.sv').readline()
    laws = re.findall(r'(?:§|law) (\w+)', first)
    sw = []; rsw = []
    for l in laws:
        s = LAWS.get(l, [])
        if s: sw.append(s[0] + '=1')
        if len(s) > 1: rsw.append(s[1] + '=1')
    res = {}
    res['on'] = run(c, 'on', [])
    res['off'] = run(c, 'off', sw) if sw else ''
    if rsw: res['roff'] = run(c, 'roff', rsw)
    res['alloff'] = run(c, 'alloff', ALLOFF)
    w = GW + '/' + rel
    def md5(t):
        m = re.search(r'md5=(\w+)', res.get(t, '')); return m.group(1) if m else '-'
    def st(t):
        m = re.search(r'strict=(\S+)', res.get(t, '')); s = m.group(1) if m else res.get(t, '-')
        m2 = re.search(r'cmp=(\d+)', res.get(t, '')); return (s if m else ' '.join(res.get(t, '-').split()[2:])) + ('|cmp' + m2.group(1) if m2 else '')
    moves = md5('on') != md5('off')
    # record check
    ga, ob, fb = rd(w + '/on.a.txt'), rd(w + '/on.b.txt'), rd(w + '/off.b.txt')
    rec = 'nodump'
    if ga and ob and fb:
        def dv(b):
            for i in range(min(len(ga), len(b))):
                x, y = ga[i].split('\t'), b[i].split('\t')
                if x[:2] != y[:2]: return i
            return min(len(ga), len(b))
        lim = min(dv(ob), dv(fb))
        away = [i for i in range(lim) if ob[i] != ga[i] and fb[i] == ga[i]]
        tow = [i for i in range(lim) if fb[i] != ga[i] and ob[i] == ga[i]]
        rec = f'away={len(away)} toward={len(tow)} div_on={dv(ob)} div_off={dv(fb)}'
        if away: rec += ' AWAY#' + ','.join(map(str, away[:5]))
    g, o, f = mset(w + '/gold/ob.txt'), mset(w + '/on.ob.txt'), mset(w + '/off.ob.txt')
    obs = 'noob'
    if g is not None and o is not None and f is not None:
        on_bad = o - g; off_bad = f - g; on_miss = g - o; off_miss = g - f
        away = sum(((on_bad - off_bad) + (on_miss - off_miss)).values())
        tow = sum(((off_bad - on_bad) + (off_miss - on_miss)).values())
        obs = f'ob_away={away} ob_toward={tow}'
    ao = ('alloff==off' if md5('alloff') == md5('off') else 'alloff!=off:' + st('alloff'))
    row = [rel, ','.join(laws), 'MOVES' if moves else 'still', st('off'), st('on'), rec, obs, ao, md5('off'), md5('on'), md5('alloff')]
    if 'roff' in res: row.append('roff=' + st('roff') + ':' + md5('roff'))
    return '\t'.join(row)
if __name__ == '__main__':
    out = sys.argv[1]
    with ThreadPoolExecutor(int(os.environ.get('JOBS', '3'))) as ex:
        rows = list(ex.map(one, sys.argv[2:]))
    with open(out, 'w') as fo:
        fo.write('case\tlaws\tmoves\toff\ton\trecords\torderblind\tcomposition\tmd5_off\tmd5_on\tmd5_alloff\textra\n')
        for r in sorted(rows): fo.write(r + '\n')
    print(open(out).read())
