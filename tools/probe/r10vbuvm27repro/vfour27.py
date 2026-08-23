#!/usr/bin/env python3
"""r10vbuvm27 FOUR-WAY, VIEW-GENERAL arm scorer -- MEASUREMENT ONLY.
golden(Surelog) is LHS.  Joins golden / pristine / patched / fixed on the SPAN
as a MULTISET (never a last-writer dict), with the DEF/ELAB view kept OUT of
the key -- the two producers label the view differently, so a view-keyed join
splits every cell.  Payload = the JUDGED shape only: object KIND (a surviving
type-query CALL vs a folded 64-bit UINT constant) and its NAME/DECOMPILE.
  usage: vfour27.py <golden.uhdm> <pris.uhdm> <pat.uhdm> [<fix.uhdm>]
"""
import subprocess, sys, collections, os
CEN = os.environ.get('CEN', '/tmp/vbuvm27_ct27cen')

def cen(db):
    d = collections.defaultdict(list)
    if not db or not os.path.exists(db):
        return None
    out = subprocess.run([CEN, db], capture_output=True, text=True).stdout
    for l in out.splitlines():
        f = l.split('\t')
        if len(f) < 5:
            continue
        sp = f[0]
        i = sp.find(':')            # a basename never contains a colon
        key = sp[i + 1:]
        # range bounds wear the same mint signature; they are not this family
        if f[1] == 'CALL' or (f[1] == 'CONST' and f[4] != 'range'):
            d[key].append(f[1] + ':' + f[2])
    return d

def main():
    G = cen(sys.argv[1]); P = cen(sys.argv[2]); Q = cen(sys.argv[3])
    F = cen(sys.argv[4]) if len(sys.argv) > 4 else None
    tot = collections.Counter()
    keys = set(G) | set(P) | set(Q) | (set(F) if F is not None else set())
    for k in sorted(keys):
        g, p, q = sorted(G.get(k, [])), sorted(P.get(k, [])), sorted(Q.get(k, []))
        f = sorted(F.get(k, [])) if F is not None else None
        def verdict(o):
            if p == g and o == g: return 'ALREADY-OK'
            if p != g and o == g: return 'FIXED'
            if p == g and o != g: return 'BROKE'
            return 'STILL'
        vq = verdict(q)
        vf = verdict(f) if F is not None else '-'
        tot['pat:' + vq] += 1
        if F is not None: tot['fix:' + vf] += 1
        if vq != 'ALREADY-OK' or (F is not None and vf != 'ALREADY-OK'):
            print('  %-16s pat=%-10s fix=%-10s G=%-28s PRI=%-28s PAT=%-28s FIX=%s'
                  % (k, vq, vf, ';'.join(g) or '<none>', ';'.join(p) or '<none>',
                     ';'.join(q) or '<none>', (';'.join(f) or '<none>') if F is not None else '-'))
    print('  TOTALS ' + '  '.join('%s=%d' % (k, v) for k, v in sorted(tot.items())))

main()
