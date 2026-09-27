#!/usr/bin/env python3
"""Group the UVM census clusters into families and rank them by objects across the five rows.
uvmfamilies.py <census_rank.csv> <out.txt>"""
import csv, sys, re, collections
rows = list(csv.DictReader(open(sys.argv[1])))
tests = ['BuildUVMPkg', 'MiniAmiq', 'Scoreboard', 'SeqDriver', 'SimpleUVM']
def fam(r):
    k, cov, site = r['key'], r['map8_coverage'], r['site']
    if 'include_file_info' in k or 'decodes r11u161+r11u166' in cov:
        return 'F1 preprocessor location model (macro-body / include lines, the r11u166 decode)'
    if k.startswith('struct|'):
        return 'F2 object multiplicity (golden-only / ours-only copies: clone bodies, typespec copies)'
    if re.match(r'span\|(enum|struct|union)_typespec\|.*under:(package|ref_typespec)', k):
        return 'F3 typedef relocation spans (last-writer moves of package aggregates)'
    if re.match(r'span\|(io_decl|[a-z_]*typespec|constant)\|.*under:(function|task|ref_typespec|io_decl|range)', k):
        return 'F4 subroutine formal / typespec / bound spans (class methods, formals)'
    if k.startswith('fullname|'):
        return 'F5 reference full names (hier_path components, method calls, io_decl refs)'
    if k.startswith('file|'):
        return 'F6 file facets (other-file, ours-empty)'
    if k.startswith('span|'):
        return 'F7 expression / statement spans outside the pp model'
    if k.startswith('name|'):
        return 'F8 names / definition names'
    return 'F9 value / order / depth'
F = collections.defaultdict(lambda: dict(n=0, per=collections.Counter(), keys=[]))
for r in rows:
    f = fam(r); n = int(r['objects'])
    F[f]['n'] += n
    for t in tests: F[f]['per'][t] += int(r[t])
    F[f]['keys'].append((n, r['map8_id'], r['key'], r['ground'], r['map8_coverage'][:70], r['site'][:120]))
tot = sum(v['n'] for v in F.values())
with open(sys.argv[2], 'w') as fo:
    fo.write(f'all objects {tot} in {len(rows)} clusters\n')
    fo.write('| rank | family | objects | ' + ' | '.join(tests) + ' | clusters |\n')
    for i, (f, v) in enumerate(sorted(F.items(), key=lambda x: -x[1]['n'])):
        fo.write(f"| {i+1} | {f} | {v['n']} | " + ' | '.join(str(v['per'][t]) for t in tests) + f" | {len(v['keys'])} |\n")
    for f, v in sorted(F.items(), key=lambda x: -x[1]['n']):
        fo.write(f'\n== {f}: top clusters\n')
        for n, cid, k, g, cov, site in sorted(v['keys'], reverse=True)[:8]:
            fo.write(f'  {n:6d} {cid} [{g}] {k} | {cov} | {site}\n')
