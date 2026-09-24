#!/usr/bin/env python3
"""worse2.py <list.tsv: label golden oursP oursL> : record-level worsening check (r11u131's
worse.py rule): NEW = a record differing from golden under the law binary but not under
pristine, before either walk diverges; EARLIER = the law walk diverges first. One line per row."""
import os, subprocess, sys, tempfile, concurrent.futures as cf
SC = '/tmp/v11u133_bin/strictcmp'
def dump(g, o):
    fa = tempfile.mktemp(prefix='v11u133_wa'); fb = tempfile.mktemp(prefix='v11u133_wb')
    subprocess.run([SC, '--max', '0', '--dump-a', fa, '--dump-b', fb, g, o], capture_output=True, timeout=1800)
    if not (os.path.exists(fa) and os.path.exists(fb)):
        for f in (fa, fb):
            if os.path.exists(f): os.unlink(f)
        return None, None
    A = open(fa).read().split('\n'); B = open(fb).read().split('\n')
    os.unlink(fa); os.unlink(fb)
    return A, B
def profile(A, B):
    diff = set(); div = None
    for i in range(min(len(A), len(B))):
        if A[i] != B[i]:
            fa, fb = A[i].split('\t'), B[i].split('\t')
            if fa[:2] != fb[:2]:
                div = i; break
            diff.add(i)
    if div is None and len(A) != len(B):
        div = min(len(A), len(B))
    return diff, div
def one(l):
    lab, g, p, q = l.rstrip('\n').split('\t')[:4]
    A, B = dump(g, p); A2, B2 = dump(g, q)
    if A is None or A2 is None:
        return f'STAGE1\t{lab}\t{"pristine" if A is None else ""} {"law" if A2 is None else ""}'
    dP, vP = profile(A, B); dL, vL = profile(A2, B2)
    lim = min(x for x in (vP, vL, len(A)) if x is not None)
    new = sorted(i for i in dL - dP if i < lim)
    gone = sorted(i for i in dP - dL if i < lim)
    earlier = (vL is not None and (vP is None or vL < vP))
    verdict = 'WORSE' if new or earlier else 'OK'
    ex = ''
    if new:
        i = new[0]; ex = ' first-new #%d A=%s | L=%s' % (i, A2[i][:140].replace('\t',' '), B2[i][:140].replace('\t',' '))
    return f'{verdict}\t{lab}\tnew={len(new)} gone={len(gone)} divP={vP} divL={vL}{ex}'
with cf.ThreadPoolExecutor(6) as ex:
    for r in ex.map(one, open(sys.argv[1]).readlines()):
        print(r, flush=True)
