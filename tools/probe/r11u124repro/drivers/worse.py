#!/usr/bin/env python3
"""worse.py <strictdiff output> <rowsP.tsv> <rowsL.tsv> — for every changed
row-mode (strictdiff.py lines), dump both walks against the same golden with
uhdm-strictcmp and compare them record by record: NEW = an object that
differs from golden under the law binary but not under pristine (same walk
index, both walks aligned there), GONE = the reverse. A row is WORSE when it
has any NEW object or its walk diverges earlier. Prints one line per row."""
import os, subprocess, sys, tempfile
SC = os.environ.get('STRICT_CMP', '/tmp/r11u124_bin/strictcmp')
def rows(p):
    d = {}
    for l in open(p):
        c, m, t, g, o = l.rstrip('\n').split('\t')
        d[(c, m, t)] = (g, o)
    return d
rp, rl = rows(sys.argv[2]), rows(sys.argv[3])
def dump(g, o):
    fa = tempfile.mktemp(prefix='r11u124_wa'); fb = tempfile.mktemp(prefix='r11u124_wb')
    subprocess.run([SC, '--max', '0', '--dump-a', fa, '--dump-b', fb, g, o], capture_output=True, timeout=900)
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
for l in open(sys.argv[1]):
    f = l.rstrip('\n').split('\t')
    if len(f) < 3 or f[0] == 'SUMMARY' or f[0].startswith('SUMMARY'):
        continue
    name, mode = f[1].rsplit('/', 1)
    corp = sys.argv[4] if len(sys.argv) > 4 else None
    key = None
    for c in ('surelog', 'uhdm2rtlil', 'probe'):
        if (c, mode, name) in rp and (corp is None or c == corp):
            key = (c, mode, name)
    if not key or key not in rl:
        print('NOROW', f[1]); continue
    g = rp[key][0]
    A, B = dump(g, rp[key][1]); A2, B2 = dump(g, rl[key][1])
    if A != A2:
        print('GOLDEN-WALK-DIFFERS', f[1]); continue
    dP, vP = profile(A, B); dL, vL = profile(A2, B2)
    lim = min(x for x in (vP, vL, len(A)) if x is not None)
    new = sorted(i for i in dL - dP if i < lim)
    gone = sorted(i for i in dP - dL if i < lim)
    earlier = (vL is not None and (vP is None or vL < vP))
    verdict = 'WORSE' if new or earlier else 'OK'
    ex = ''
    if new:
        i = new[0]; ex = ' first-new #%d A=%s | L=%s' % (i, A2[i][:120], B2[i][:120])
    print(f'{verdict}\t{f[0]}\t{f[1]}\tnew={len(new)} gone={len(gone)} divP={vP} divL={vL}{ex}')
