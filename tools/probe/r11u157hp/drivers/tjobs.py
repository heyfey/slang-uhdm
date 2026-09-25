#!/usr/bin/env python3
"""r11u157: the job list of the hier_path element family. Every row-mode and probe case the seventh map
(tools/probe/r11u156map clusters.csv / probe_clusters.csv) files under the target clusters, pointed at a sweep
workdir (<corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt} + probe/<rel __>.uhdm).
Args: <map dir> <sweep workdir> <out rows.tsv> <out probe.tsv> [clusters...]. Fail-closed fence (names from RESUME.md)."""
import csv, os, re, sys, glob
mapd, wd, out, pout = sys.argv[1:5]
T = set(sys.argv[5:]) or {'N0001','N0007','N0018','N0097','N0098','N0099','N0101','N0102','N0071'}
_R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'RESUME.md')
_t = open(_R).read()
FENCED = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', _t, re.S).group(1)))
assert len(FENCED) == 4, 'fence list unreadable: refusing to run'
rows = sorted({(r['corpus'], r['mode'], r['test']) for r in csv.DictReader(open(f'{mapd}/clusters.csv')) if r['cluster_id'] in T})
cases = sorted({r['case'] for r in csv.DictReader(open(f'{mapd}/probe_clusters.csv')) if r['cluster_id'] in T})
n = bad = fen = 0
with open(out, 'w') as f:
    for c, m, t in rows:
        if t in FENCED: fen += 1; continue
        d = [x for x in glob.glob(f'{wd}/{c}/{m}/{t}-*') if os.path.basename(x).rsplit('-', 1)[0] == t]
        if len(d) != 1: print('MISSING', c, m, t); bad += 1; continue
        cm = open(f'{d[0]}/cmds.txt').read()
        g = re.search(r'golden cache (?:hit|stored?) (\S+?)\)', cm)
        gp = f'{g.group(1)}/golden.uhdm' if g else ''
        if not os.path.exists(gp) or not os.path.exists(f'{d[0]}/slang.uhdm'): print('NOFILE', c, m, t); bad += 1; continue
        f.write('\t'.join([c, m, t, gp, f'{d[0]}/slang.uhdm']) + '\n'); n += 1
repo = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..')
sys.path.insert(0, os.path.join(repo, 'scripts'))
import check_probe as cp
pn = pm = 0
with open(pout, 'w') as f:
    for rel0 in cases:
        rel = rel0 + '/dut.sv' if not rel0.endswith('.sv') else rel0
        cand = [x for x in cp.cases(None) if x.startswith(rel0 + '/') or x == rel0]
        if len(cand) != 1: print('PMISS', rel0, cand[:3]); pm += 1; continue
        rel = cand[0]
        g = os.path.join(cp.cache_dir(rel), 'golden.uhdm'); o = os.path.join(wd, 'probe', rel.replace('/', '__') + '.uhdm')
        if not (os.path.exists(g) and os.path.exists(o)): print('PNOFILE', rel, os.path.exists(g), os.path.exists(o)); pm += 1; continue
        f.write('\t'.join(['probe', 'default', rel.replace('/', '__'), g, o, rel]) + '\n'); pn += 1
print('rows', n, 'bad', bad, 'fenced_skipped', fen, 'probe', pn, 'pmiss', pm)
