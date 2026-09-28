#!/usr/bin/env python3
"""r11u196: the first differing strict record of every STRICT_NOTEQUAL probe case of a sweep.
usage: probeheads.py <sweep workdir holding probe/ and probe.csv> <out.tsv> [--max N]
Reads the probe databases the sweep wrote (<wd>/probe/<rel with / -> __>.uhdm) and the golden cache
entry check_probe.cache_dir(rel) names.  Refuses (fail closed) case paths naming a fenced test."""
import csv, os, re, subprocess, sys
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp, verify_golden as vg
fl = [l for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')]
FENCED = fl[0].split('=', 1)[1].strip().strip('"\'').split() if fl else []
if len(FENCED) != 4:
    sys.exit('probeheads: FENCED not 4 names')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, FENCED)) + r')\b')
wd, out = sys.argv[1], sys.argv[2]
mx = sys.argv[4] if len(sys.argv) > 4 and sys.argv[3] == '--max' else '3'
scmp = os.environ.get('SCMP', '/tmp/r11u196_bin/uhdm-strictcmp')
rows = [r for r in csv.DictReader(open(os.path.join(wd, 'probe.csv'))) if r['status'] == 'STRICT_NOTEQUAL']
with open(out, 'w') as f:
    for r in rows:
        rel = r['case']
        if fre.search(rel):
            continue
        g = vg.cache_load(cp.cache_dir(rel))
        db = os.path.join(wd, 'probe', rel.replace('/', '__') + '.uhdm')
        if not g or not g[1] or not os.path.isfile(db):
            f.write(f'{rel}\t{r["strict"]}\tMISSING\n'); continue
        p = subprocess.run([scmp, '--max', mx, g[1], db], capture_output=True, text=True)
        recs = []
        lines = p.stdout.splitlines()
        for i, l in enumerate(lines):
            if l.startswith('#') and i + 2 < len(lines):
                a = lines[i + 1].split('\t'); b = lines[i + 2].split('\t')
                recs.append(l.strip() + '|' + '|'.join(x for x in a[1:3]) + '|A=' + ':'.join(a[5:10]) + '|B=' + ':'.join(b[5:10]) + '|Afn=' + a[4] + '|Bfn=' + b[4])
        f.write(rel + '\t' + r['strict'] + '\t' + '\t'.join(recs) + '\n')
