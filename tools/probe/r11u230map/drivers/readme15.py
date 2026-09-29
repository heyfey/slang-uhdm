#!/usr/bin/env python3
"""r11u230map: fill README.src.md's <<MARKERS>> from the map's outputs into README.md (the tables are generated, the
prose is the source file's). Args: <map dir> <work W> <add dir>"""
import sys, os, re, json, csv, collections
M, W, A = sys.argv[1:4]
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
FEN = fenced()
src = open(f'{M}/README.src.md').read()
rep = open(f'{W}/report.txt').read()
esc = lambda s: str(s).replace('|', '\\|')
T = lambda n: open(f'{M}/evidence/tables/{n}').read().rstrip('\n')
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{M}/cluster_index.csv'))}
SW = json.load(open(f'{M}/evidence/writers/sites_writer.json'))
GOV = json.load(open(f'{M}/evidence/ground_override.json'))
WG = json.load(open(f'{M}/evidence/writers/writer_ground.json'))
GA = {'ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'}; GB = {'TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp'}
gof = lambda f: 'A' if f in GA else ('B' if f in GB else '?')
V = {}
# ---- writer statistics
how = collections.Counter(v['how'] for v in SW.values())
g = collections.Counter(WG.get(c, '?') for c in SW)
fac = collections.Counter(v['field'].split(':')[0] for v in SW.values())
alt = [c for c, v in SW.items() if 'alt_writer' in v]
altdiff = [c for c in alt if SW[c].get('alt_owner') != SW[c]['owner']]
npw = int(open(f'{M}/evidence/writers/npw.txt').read().split()[0])
V['NPW'] = str(npw)
V['WRITER_STATS'] = (f"last write by a watchpoint {how['watch']}, by a setter {how['setter']}, a full name through the parent chain {how['parent']}, "
                     f"no write after the mint {how['mint']}; writer frame on ground A {g['A']}, B {g['B']}, elsewhere {g['?']}")
nstruct = sum(1 for r in CI.values() if r['key'].split('|')[0] in ('struct', 'order'))
V['WRITER_COVERAGE'] = (f"{len(SW)} of the 695 clusters, every one with a field whose key is OPEN or carries a corpus row (by facet: "
                        + ', '.join(f'{k} {n}' for k, n in fac.most_common()) + f"); the {nstruct} struct / order clusters have no field and keep "
                        "their mint pin (map 14's, re-pinned by drivers/pinmulti.py on the 28 whose example object changed: all BlackBePipeInt t's "
                        "shifted records, N0001, N0014, N0073, N0097, N0123, N0427, N0853, N1179, N0905, N1446, N2476). "
                        f"{len(alt)} row clusters whose smallest example is a probe case were pinned again on their smallest corpus row "
                        f"(PW_PREFER=corpus); the two pins name different writer files on {len(altdiff)}: " + (', '.join(f"{c} (probe {SW[c]['alt_owner']}, row {SW[c]['owner']})" for c in sorted(altdiff)) or 'none') + '.')
ne = [c for c, v in SW.items() if v.get('mint_owner') and v['owner'] != v['mint_owner']]
V['W_NE_M'] = str(len(ne))
V['W_GROUNDS'] = f"A {g['A']}, B {g['B']}, neither {g['?']} (a writer in UHDM's library or uhdm_main's elaboration)"
cross = [c for c in CI if CI[c].get('writer_chain_grounds') == 'A+B']
openrow = [c for c in cross if not CI[c]['coverage'].startswith('COVERED') and int(CI[c]['rows_after_pairs']) > 0]
V['W_CROSS'] = f"{len(cross)} clusters ({len(openrow)} of them OPEN with a row after the pairs: {' '.join(sorted(openrow)[:40])}{' ...' if len(openrow) > 40 else ''})"
conf = []
for c, gg in sorted(GOV.items()):
    if c in CI and WG.get(c) in ('A', 'B') and WG[c] != gg and (int(CI[c]['rows']) > 0 or int(CI[c]['probe_cases']) > 0):
        conf.append(f"{c} (override {gg}, writer frame {WG[c]}: {esc(SW[c]['writer'][:90])})")
V['OVR_CONFLICTS'] = (f"**Overrides the writer frame contradicts** ({len(conf)}; the override stands, the writer chain is printed beside it): " + '; '.join(conf)) if conf else ''
# ---- tables
V['T_HEADS'] = open(f'{M}/evidence/writers/heads_table.md').read().rstrip('\n')
V['T_FAIL'] = T('t_fail.md'); V['T_PFIRST'] = T('t_pfirst.md'); V['T_T1'] = T('t_t1.md')
sec4 = rep.split('== 4.')[1].split('== 5.')[0]
po = re.search(r'probe-only OPEN clusters with the most cases: (.*)', sec4).group(1)
laws = re.search(r'laws with the most NE cases: (.*)', sec4).group(1)
sec5 = rep.split('== 5.')[1].split('== 6.')[0]
heads = re.findall(r'^\| (N\d+) \| (\d+) \|', sec5, re.M)
alone = sorted(((c, r) for c, r in CI.items() if int(r['alone_on_top_of_pairs']) > 0), key=lambda x: -int(x[1]['alone_on_top_of_pairs']))
ga = [c for c, r in CI.items() if not r['coverage'].startswith('COVERED') and int(r['rows_after_pairs']) > 0 and r['ground'] == 'A']
V['T_OPEN_NOTES'] = (
    "**Clusters that clear a row-mode ALONE on top of both pairs**: " + ('; '.join(f"{c} ({r['alone_on_top_of_pairs']} row-modes; tests carrying it: {r['example_tests']})" for c, r in alone) or 'none') + ". "
    "**Clusters that head the most rows after the pairs**: " + ' '.join(f'{c} ({n})' for c, n in heads[:12]) + ". "
    f"**Ground-A OPEN clusters with a row after the pairs** ({len(ga)}): " + ' '.join(sorted(ga)) + " (the rest of ground A is credited to pair A: the UVM and Earlgrey A families, optimistic). "
    f"**Probe-only OPEN clusters with the most cases**: {po}. **Laws with the most STRICT_NOTEQUAL cases** (of their cases): {laws}. "
    f"By ground the ranked table's grounds are [evidence/tables/t_groundA.md](evidence/tables/t_groundA.md) and [t_groundB.md](evidence/tables/t_groundB.md).")
# ---- yields
sec2 = rep.split('== 2.')[1].split('== 4.')[0]
L = sec2.strip('\n').split('\n')
V['YIELD_LINE'] = '; '.join(x.strip() for x in L[1:4])
m = re.search(r'FAIL LIST AFTER BOTH PAIRS: (.*)', sec2).group(1); mn = re.search(r'NAMED ONLY (.*)', sec2).group(1)
V['AFTER_LINE'] = f"**{m.split(';')[0]}** optimistic; named-only: {mn.split('FAIL LIST AFTER NAMED: ')[1]}"
V['T_YIELD'] = '```\n' + sec2.strip('\n') + '\n```'
# ---- downstream
DS = list(csv.DictReader(open(f'{M}/evidence/downstream/dsfaces_P.csv')))
O = {r['case']: r['verdict'] for r in csv.DictReader(open(f'{os.path.dirname(M)}/r11u222map/evidence/downstream/dsfaces_P.csv'))}
cnt = collections.Counter(r['verdict'] for r in DS)
V['DS_COUNTS'] = ', '.join(f'{n} {k}' for k, n in cnt.most_common())
rows = ['| face | cases | verdict at `97343175` | map 14 |', '|---|---|---|---|']
grp = collections.OrderedDict()
for r in DS:
    c = r['case']; key = c.split('/cases/')[0].replace('tools/probe/', '') + ('/' + c.split('/cases/')[1].split('/')[0] if '/cases/' in c else '')
    grp.setdefault((key, r['verdict'], O.get(c, '-')), []).append(c.split('/')[-1])
for (k, v, o), cs in grp.items():
    rows.append(f"| {k} | {' '.join(cs)} | {'**' + v + '**' if v in ('DIVERGENT', 'STATUS_DIFF') or (o != '-' and o != v) else v} | {o} |")
V['T_DS'] = '\n'.join(rows) + '\n\nChanged against map 14 (same case, `551c9751` -> `97343175`): ' + (', '.join(f"{r['case']} {O[r['case']]} -> {r['verdict']}" for r in DS if r['case'] in O and O[r['case']] != r['verdict']) or 'none') + ' (pass 224\'s string-literal laws; their spans reach the RTLIL src attributes).'
# ---- family
sec9 = rep.split('== 9. family view')[1]
V['T_FAMILY'] = sec9.strip('\n').replace('   single-cluster rows at 97343175:', '\n**Single-cluster rows at `97343175`**:').replace('   NEAR rows', '\n**Near rows**').replace('   two open clusters', '\n**Two open clusters**')
V['UVM_TOP'] = "by today's ids: F2 N0182 1,924, N0024 780, N0478 762, N0420 717, N0495 576, N0408 481, N0496 468, N0538 440; F5 N0565 590, N0492 585, N0571 552 (evidence/uvm/families.txt, whose status column is map 8's)."
# ---- greedy
sec8 = rep.split('== 8. ')[1].split('== 8b.')[0]; sec8b = rep.split('== 8b. ')[1].split('== 9.')[0]
def trim(block):
    out = []
    for l in block.split('\n'):
        if l.startswith('| ') and not l.startswith('| step') and not l.startswith('|---'):
            p = l.split(' | ')
            ids = p[1].split(' + ')
            if len(ids) > 14: p[1] = ' + '.join(ids[:14]) + f' ... (+{len(ids) - 14})'
            if len(p) > 7: p[6] = p[6][:120] + (' ...' if len(p[6]) > 120 else '')
            l = ' | '.join(p)
        out.append(l)
    return '\n'.join(out)
V['T_GREEDY'] = ('### 13a. On top of both live pairs (optimistic)\n\n' + trim(sec8.strip('\n')).replace('## ground', '**list') .replace(' candidate sets', ' candidate sets**')
                 + '\n\n### 13b. On top of the NAMED heads only\n\n' + trim(sec8b.strip('\n')).replace('## ground', '**list').replace(' candidate sets', ' candidate sets**'))
V['T_JOINT'] = '```\n' + open(f'{M}/evidence/rowsets.txt').read().rstrip('\n') + '\n```'
V['ADDENDUM'] = open(f'{M}/evidence/addendum_9c9c11d6/addendum.md').read().rstrip('\n')
V['FILES'] = open(f'{M}/evidence/files.md').read().rstrip('\n')
V['SCRATCH'] = os.environ.get('MAP_SCRATCH', '(not measured)')
out = src
for _ in range(2): out = re.sub(r'<<([A-Z0-9_]+)>>', lambda mm: V.get(mm.group(1), mm.group(0)), out)
left = re.findall(r'<<([A-Z0-9_]+)>>', out)
assert not left, left
assert not any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(f) + r'(?![A-Za-z0-9_])', out) for f in FEN), 'fenced name in README'
open(f'{M}/README.md', 'w').write(out)
print('README.md', len(out.splitlines()), 'lines')
