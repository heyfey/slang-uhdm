#!/usr/bin/env python3
# compose.py: join the four sweeps (ON = both landings on, OF = both off, X0 = pass 140 off, X4 = pass 144 off)
# row by row and classify every row whose status or strict cell differs anywhere.
import csv, os, sys
FENCED = set(os.environ.get('FENCED', '').split())  # slang-fenced test names from the environment, never spelled here
W = {t: f'/tmp/r11u149_w{t}' for t in ('ON', 'OF', 'X0', 'X4')}
import subprocess
def landed(commit):
    # the rows the landing commit re-baselined to equal (its conversions), read from git
    out = subprocess.run(['git', '-C', '/tmp/wt_r11u149', 'show', commit, '--', 'results/golden_surelog.csv',
                          'results/golden_uhdm2rtlil.csv', 'results/golden_probe.csv'], capture_output=True, text=True).stdout
    corp = None; keys = set()
    for ln in out.split('\n'):
        if ln.startswith('+++ '): corp = 'probe' if 'probe' in ln else ('surelog' if 'surelog' in ln else 'uhdm2rtlil')
        elif ln.startswith('+') and not ln.startswith('+++'):
            f = ln[1:].split(',')
            if corp == 'probe' and f[1] == 'EQUAL': keys.add(('probe', f[0], '-'))
            elif corp != 'probe' and f[2] == 'CMP_EQUAL': keys.add((corp, f[0], f[1][0]))
    return keys
L140, L144 = landed('c24699f1'), landed('b2199096')
def load(t, corp):
    f = f"{W[t]}/{corp}.csv"
    if not os.path.exists(f): return None
    out = {}
    for r in csv.DictReader(open(f)):
        if corp == 'probe': out[('probe', r['case'], '-')] = (r['status'], r['strict'])
        else: out[(corp, r['name'], r['mode'][0])] = (r['status'], r['strict'])
    return out
def eq(v): return v and v[0] in ('CMP_EQUAL', 'EQUAL')
def claim(k):
    return '+'.join(x for x, S in (('140', L140), ('144', L144)) if k in S) or '-'
tot = {}
for corp in ('probe', 'surelog', 'uhdm2rtlil'):
    S = {t: load(t, corp) for t in W}
    keys = sorted(set().union(*[set(v) for v in S.values() if v]))
    keys = [k for k in keys if k[1] not in FENCED]
    for k in keys:
        v = {t: (S[t] or {}).get(k) for t in W}
        conv_on = eq(v['ON']); off = eq(v['OF'])
        if v['ON'] == v['OF'] and (not S['X0'] or v['X0'] == v['ON']) and (not S['X4'] or v['X4'] == v['ON']): continue
        e = ''.join('E' if eq(v[t]) else ('n' if v[t] else '?') for t in ('OF', 'X0', 'X4', 'ON'))
        cl = claim(k)
        if conv_on and not off: kind = 'CONVERSION'
        elif off and not conv_on: kind = 'REGRESSION'
        elif conv_on and off: kind = 'EQUAL-BOTH-ENDS'
        else: kind = 'CHANGE'
        # suspect: equal only with both on and both off (single-off breaks it)
        if eq(v['ON']) and eq(v['OF']) and S['X0'] and S['X4'] and (not eq(v['X0']) or not eq(v['X4'])): kind = 'SUSPECT'
        # attribution from the single-off sweeps
        att = []
        if S['X0'] and S['X4']:
            if v['X0'] != v['ON']: att.append('140')
            if v['X4'] != v['ON']: att.append('144')
        tot[(corp, kind)] = tot.get((corp, kind), 0) + 1
        print(f"{kind}\t{corp}\t{k[1]}\t{k[2]}\tpattern(OF,X0,X4,ON)={e}\tclaimed={cl}\tmoved_by={'+'.join(att) or '?'}\tOF={v['OF'][1] if v['OF'] else None}\tON={v['ON'][1] if v['ON'] else None}")
for k in sorted(tot): print('TOTAL', k, tot[k], file=sys.stderr)
