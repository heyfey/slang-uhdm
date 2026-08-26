#!/usr/bin/env python3
"""r10earl100 -- MEASUREMENT ONLY.  Three-way listing-census scorer.

Runs ct100cen over every (golden, ours) database pair in a verify_golden
workdir and scores, per database:
  BOTH-SAME / TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG on the SIG multiset,
  plus the per-scope COUNT columns (nV, nN) that are what the judge's
  vector SafeCompare actually reports.
MULTISET join (Counter), never a last-writer dict: a key can repeat.
"""
import os, sys, subprocess, collections, json

CEN = os.environ.get('CT100CEN', '/tmp/r10earl100_s/ct100cen')

def run(db):
    p = subprocess.run([CEN, db], capture_output=True, text=True, timeout=1800)
    if p.returncode != 0:
        return None
    sig = collections.Counter(); cnt = {}
    for line in p.stdout.splitlines():
        if line.startswith('SIG '):
            k, _, v = line[4:].partition('\t'); sig[(k, v)] += 1
        elif line.startswith('CNT '):
            k, _, v = line[4:].partition('\t'); cnt[k] = v
    return sig, cnt

def golden_of(work):
    cf = os.path.join(work, 'cmds.txt')
    if not os.path.exists(cf): return None
    for line in open(cf):
        if 'golden cache hit' in line:
            return os.path.join(line.split('golden cache hit ')[1].strip().rstrip(')'), 'golden.uhdm')
    return None

def pairs(workroot):
    for mode in sorted(os.listdir(workroot)):
        md = os.path.join(workroot, mode)
        if not os.path.isdir(md): continue
        for d in sorted(os.listdir(md)):
            w = os.path.join(md, d)
            ours = os.path.join(w, 'slang.uhdm')
            g = golden_of(w)
            if g and os.path.exists(g) and os.path.exists(ours):
                yield mode, d, g, ours

def main():
    workroot = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else '-'
    fh = sys.stdout if out == '-' else open(out, 'wt')
    tot = collections.Counter()
    for mode, name, g, o in pairs(workroot):
        try:
            rg = run(g); ro = run(o)
        except Exception as e:
            print('ERR', mode, name, e, file=fh); continue
        if rg is None or ro is None:
            print('RESTORE_FAIL', mode, name, file=fh); continue
        gs, gc = rg; os_, oc = ro
        only_g = gs - os_; only_o = os_ - gs
        same = sum((gs & os_).values())
        tot['pairs'] += 1
        tot['same'] += same
        tot['only_golden'] += sum(only_g.values())
        tot['only_ours'] += sum(only_o.values())
        # count-column disagreements, per scope
        badV = badN = 0; scopes = 0
        for k, v in gc.items():
            scopes += 1
            if k in oc and oc[k] != v:
                gv = dict(x.split('=') for x in v.split())
                ov = dict(x.split('=') for x in oc[k].split())
                if gv['nV'] != ov['nV']: badV += 1
                if gv['nN'] != ov['nN']: badN += 1
        tot['scopes'] += scopes
        tot['badV'] += badV; tot['badN'] += badN
        if only_g or only_o or badV or badN:
            print('DB %s/%s  onlyG=%d onlyO=%d badV=%d badN=%d scopes=%d'
                  % (mode, name, sum(only_g.values()), sum(only_o.values()),
                     badV, badN, scopes), file=fh)
            for k, c in sorted(only_g.items()):
                print('   G-ONLY x%d %s\t%s' % (c, k[0], k[1]), file=fh)
            for k, c in sorted(only_o.items()):
                print('   O-ONLY x%d %s\t%s' % (c, k[0], k[1]), file=fh)
    print('TOTAL', json.dumps(dict(tot)), file=fh)
    if fh is not sys.stdout: fh.close()

main()
