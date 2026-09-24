#!/usr/bin/env python3
"""Adversarial soundness sweep: on a pair the canonical walk calls equal, change
ONE judge-blind field of ONE object (golden side or ours) and require the
canonical verdict to become STRICT_NOTEQUAL.  Every object the raw walk enters is
mutated in turn (endcol := endcol+1; for expressions inside a typespec/enum_const
subtree also VpiValue := 'UINT:987654'), on each side.  Control per pair: a
mutation that writes the CURRENT value back (round trip) must stay STRICT_EQUAL.

usage: mutation_sweep.py <runall.csv> <pairs.tsv> <out.tsv> [maxobjs] [jobs] [row filter regex]
Rows taken: canonical verdict equal and raw verdict not equal (the converted rows),
plus any row matching the filter.  maxobjs caps the objects per side (evenly sampled,
every in-canon object kept first)."""
import concurrent.futures, csv, os, re, subprocess, sys, tempfile

MUT = '/tmp/r11u123_bin/mutate'
SC = os.environ.get('SC', '/tmp/r11u123_bin/uhdm-strictcmp')
runall, pairs, out = sys.argv[1], sys.argv[2], sys.argv[3]
maxobjs = int(sys.argv[4]) if len(sys.argv) > 4 else 400
jobs = int(sys.argv[5]) if len(sys.argv) > 5 else 3
filt = sys.argv[6] if len(sys.argv) > 6 else None
P = {}
for l in open(pairs):
    f = l.rstrip('\n').split('\t')
    P[(f[0], f[1], f[2])] = (f[5], f[6])
rows = []
for r in csv.DictReader(open(runall)):
    k = (r['corpus'], r['mode'], r['test'])
    if (r['raw_v'] != 'equal' and r['can_v'] == 'equal') or (filt and re.search(filt, '/'.join(k))):
        rows.append(k)
TMP = '/tmp/r11u123_mut'
os.makedirs(TMP, exist_ok=True)


def listing(db):
    o = subprocess.run([MUT, db, '--list'], capture_output=True, text=True).stdout
    return [l.split('\t') for l in o.splitlines()]


def rawdump(db, other, side):
    fd, p = tempfile.mkstemp(dir=TMP)
    os.close(fd)
    args = [SC, '--max', '0', '--no-canon']
    args += ['--dump-a', p, db, other] if side == 'A' else ['--dump-b', p, other, db]
    subprocess.run(args, capture_output=True)
    recs = [l.rstrip('\n').split('\t') for l in open(p, errors='surrogateescape')]
    os.remove(p)
    return recs


def trial(k, side, db, other, idx, field, val):
    fd, m = tempfile.mkstemp(dir=TMP, suffix='.uhdm')
    os.close(fd)
    rc = subprocess.run([MUT, db, m, str(idx), field, val], capture_output=True).returncode
    if rc != 0:
        os.remove(m)
        return None
    a, b = (m, other) if side == 'A' else (other, m)
    r = subprocess.run([SC, '--max', '0', a, b], capture_output=True, text=True)
    os.remove(m)
    first = ''
    for l in r.stdout.splitlines():
        if l.startswith('STRICT_NOTEQUAL'):
            first = l.split()[1]
    return r.returncode, first


def work(k):
    g, o = P[k]
    res = []
    for side, db, other in (('A', g, o), ('B', o, g)):
        L = listing(db)
        R = rawdump(db, other, side)
        if len(L) != len(R) or any(L[i][1] != R[i][1] for i in range(len(L))):
            res.append((k, side, -1, 'ALIGN', 'listing!=rawdump', '', ''))
            continue
        # control: write the current endcol back
        c = trial(k, side, db, other, 0, 'endcol', R[0][9] or '0')
        res.append((k, side, 0, 'control', 'endcol=same', c[0], c[1]))
        inc = [i for i in range(len(L)) if L[i][3] == '1']
        rest = [i for i in range(len(L)) if L[i][3] != '1']
        pick = inc[:maxobjs]
        if len(pick) < maxobjs and rest:
            step = max(1, len(rest) // (maxobjs - len(pick)))
            pick += rest[::step][:maxobjs - len(pick)]
        for i in sorted(pick):
            v = str(int(R[i][9] or 0) + 1)
            t = trial(k, side, db, other, i, 'endcol', v)
            res.append((k, side, i, L[i][1] + ('*' if L[i][3] == '1' else ''), 'endcol', t[0], t[1]))
            if L[i][3] == '1' and R[i][10:13] != ['', '', ''] or (L[i][3] == '1' and L[i][1] in ('constant', 'operation', 'ref_obj')):
                t = trial(k, side, db, other, i, 'value', 'UINT:987654')
                if t:
                    res.append((k, side, i, L[i][1] + '*', 'value', t[0], t[1]))
    return res


with open(out, 'w') as f, concurrent.futures.ThreadPoolExecutor(jobs) as pool:
    for res in pool.map(work, rows):
        for (k, side, i, ty, fld, rc, first) in res:
            f.write('\t'.join(map(str, ['/'.join(k), side, i, ty, fld, rc, first])) + '\n')
        f.flush()
print('DONE', len(rows))
