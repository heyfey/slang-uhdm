#!/usr/bin/env python3
"""v11u186 case judge: python3 v11u186_case.py <outdir> <bin1,bin2,...> <casedir>... 
Per case: golden (Surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0, cached by text md5),
ours per binary (dut.sv --single-unit --nobuiltin), uhdm-cmp rc + stderr lines, strict verdict, db md5.
Fence: refuses any path containing a fenced name (word boundary). Prints TSV."""
import os, sys, subprocess, hashlib, re, concurrent.futures as cf, shutil
FEN = os.environ.get('FENCED', '').split()
assert len(FEN) == 4, 'FENCED not set'
SL = os.environ['SURELOG']; CMP = os.environ['UHDM_CMP']; SC = os.environ['STRICT_CMP']
out, bins, dirs = sys.argv[1], sys.argv[2].split(','), sys.argv[3:]
def fenced(p): return any(re.search(r'\b%s\b' % re.escape(f), p) for f in FEN)
def srcmd5(d):
    h = hashlib.md5()
    for f in sorted(os.listdir(d)):
        if f.endswith(('.sv', '.svh', '.v', '.vh')):
            h.update(f.encode()); h.update(open(os.path.join(d, f), 'rb').read())
    return h.hexdigest()[:16]
def golden(d):
    g = f'/tmp/v11u186_gold/{srcmd5(d)}'
    if not os.path.exists(g + '/golden.uhdm'):
        w = g + '/w'; os.makedirs(w, exist_ok=True)
        subprocess.run([SL, '-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv', '-mt', '0', '-mp', '0', '-o', w],
                       cwd=d, capture_output=True, timeout=600)
        u = [os.path.join(r, f) for r, _, fs in os.walk(w) for f in fs if f.endswith('.uhdm')]
        if u: shutil.copy(u[0], g + '/golden.uhdm')
        shutil.rmtree(w, ignore_errors=True)
    return g + '/golden.uhdm' if os.path.exists(g + '/golden.uhdm') else None
def one(d):
    d = os.path.abspath(d)
    if fenced(d): return d + '\tFENCED-REFUSED'
    g = golden(d)
    key = re.sub(r'.*/tools/probe/', '', d).replace('/', '_')
    cols = [re.sub(r'.*/tools/probe/', '', d)]
    for b in bins:
        o = f'{out}/{os.path.basename(b)}/{key}'; os.makedirs(o, exist_ok=True)
        db = o + '/ours.uhdm'
        if os.path.exists(db): os.remove(db)
        r = subprocess.run([b, 'dut.sv', '--single-unit', '--nobuiltin', '-o', db], cwd=d, capture_output=True, timeout=600)
        if not os.path.exists(db) or os.path.getsize(db) == 0:
            cols.append(f'SLANG_FAIL(rc={r.returncode})'); continue
        m = hashlib.md5(open(db, 'rb').read()).hexdigest()[:8]
        if not g: cols.append(f'SURELOG_FAIL#{m}'); continue
        c = subprocess.run([CMP, g, db], capture_output=True, text=True)
        cl = len([l for l in c.stderr.splitlines() if l.strip()])
        s = subprocess.run([SC, '--max', '0', g, db], capture_output=True, text=True, timeout=600)
        if s.returncode == 0 and s.stdout.startswith('STRICT_EQUAL '): v = 'EQUAL'
        elif s.returncode == 1: v = 'NOT_EQUAL'
        else:
            f = n = ''
            for l in s.stdout.splitlines():
                if l.startswith('STRICT_NOTEQUAL '): f = l.split(' ', 1)[1].strip()
                if 'objects_differing=' in l: n = l.split('objects_differing=')[1].split()[0]
            v = f'SN:{f}({n})'
        cols.append(f'{v}|cmp{c.returncode}/{cl}|rc{r.returncode}#{m}')
    return '\t'.join(cols)
with cf.ThreadPoolExecutor(3) as ex:
    for line in ex.map(one, dirs): print(line, flush=True)
