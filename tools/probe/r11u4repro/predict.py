#!/usr/bin/env python3
# r11u4 PREDICTOR — names, from PRISTINE databases ALONE, every test whose
# database § ifacePortViewPaFoldsDeclDefault can move, and WHICH FACE moves it.
#
# Our emitter anchors a PORT VIEW's interface_inst at COLUMN 0 (the col-0 tail
# duplicate lands there too; a home view keeps the instantiation statement's
# real column and a def view the declaration's), so a col-0 interface_inst is
# the candidate set.  For each of its param_assigns the law rewrites:
#   A  vpiOverriden:1                                  -> cleared
#   B  the DEF view's Rhs for that name is an op75      -> our Rhs replaced
#   C  the DEF view's Rhs is a NON-75 operation and our
#      Rhs is a constant carrying a |vpiTypespec:       -> the ref dropped
#
# This is a SUPERSET: the dump does not say whether a view is the one exempt
# cell (a modport-qualified port reached by a NAMED connection), so views that
# the law leaves alone are predicted here too.  Every ACTUAL mover must fall
# inside this set and be attributed by name.
import subprocess, sys, os, glob, re
DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'

def ind(l): return len(l) - len(l.lstrip(' '))

def parse(out):
    """-> (defviewRhsKind{defname:{param:kind}}, [(fullname,col0,param,ovr,rhskind,hasts)])"""
    L = out.split('\n')
    rows = []
    defrhs = {}
    cur = None; curdef = None; curcol = None
    i = 0
    while i < len(L):
        m = re.search(r'\\_interface_inst: (\S+) \(([^)]*)\)(.*)$', L[i])
        if m:
            curdef, cur = m.group(1), m.group(2)
            cm = re.search(r'line:\d+:(\d+)', m.group(3))
            curcol = cm.group(1) if cm else None
        if cur and re.match(r'^\s*\|vpiParamAssign:', L[i]):
            b = ind(L[i]); j = i + 1; blk = []
            hb = ind(L[j]) if j < len(L) else 0
            j += 1
            while j < len(L) and (L[j].strip() == '' or ind(L[j]) > hb):
                blk.append(L[j]); j += 1
            ovr = any(ind(x) == hb + 2 and x.strip() == '|vpiOverriden:1' for x in blk)
            pname = None; rk = None; hasts = False
            for k, x in enumerate(blk):
                if ind(x) == hb + 2 and x.strip() == '|vpiLhs:':
                    mm = re.match(r'\s*\\_parameter: \(([^)]*)\)', blk[k+1])
                    if mm: pname = mm.group(1).split('.')[-1]
                if ind(x) == hb + 2 and x.strip() == '|vpiRhs:':
                    h = blk[k+1]; rb = ind(h)
                    mm = re.match(r'\s*\\_(\w+):', h)
                    rk = mm.group(1) if mm else '?'
                    if rk == 'operation':
                        kk = k + 2
                        while kk < len(blk) and (blk[kk].strip() == '' or ind(blk[kk]) > rb):
                            if ind(blk[kk]) == rb + 2 and blk[kk].strip().startswith('|vpiOpType:'):
                                rk = 'op' + blk[kk].strip()[11:]; break
                            kk += 1
                    kk = k + 2
                    while kk < len(blk) and (blk[kk].strip() == '' or ind(blk[kk]) > rb):
                        if ind(blk[kk]) == rb + 2 and blk[kk].strip() == '|vpiTypespec:': hasts = True
                        kk += 1
            if pname:
                if cur == curdef:
                    defrhs.setdefault(curdef, {})[pname] = rk
                rows.append((cur, curdef, curcol, pname, ovr, rk, hasts))
            i = j; continue
        i += 1
    return defrhs, rows

def scan(path):
    try:
        out = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=1800).stdout
    except Exception:
        return None
    defrhs, rows = parse(out)
    faces = set()
    for full, dfn, col, p, ovr, rk, hasts in rows:
        if col != '0' or full == dfn:
            continue
        d = defrhs.get(dfn, {}).get(p)
        if ovr: faces.add('A')
        if d == 'op75' and rk == 'op75': faces.add('B')
        if d and d.startswith('op') and d != 'op75' and rk == 'constant' and hasts: faces.add('C')
    return ''.join(sorted(faces))

if __name__ == '__main__':
    wd = sys.argv[1]
    jobs = []
    for d in sorted(glob.glob(os.path.join(wd, '*', '*'))):
        f = os.path.join(d, 'slang.uhdm')
        if not os.path.isfile(f): continue
        jobs.append((os.path.basename(d).rsplit('-', 1)[0],
                     os.path.basename(os.path.dirname(d)), f))
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=3) as ex:
        res = list(ex.map(lambda t: (t[0], t[1], scan(t[2])), jobs))
    npred = 0; nfail = 0
    for n, m, h in sorted(res):
        if h is None: print('SCAN-FAIL %s %s' % (n, m)); nfail += 1
        elif h: print('PREDICT-MOVER %s %s faces=%s' % (n, m, h)); npred += 1
    print('-- scanned=%d predicted=%d fail=%d' % (len(res), npred, nfail))
