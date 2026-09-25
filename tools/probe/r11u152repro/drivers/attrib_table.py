#!/usr/bin/env python3
"""attrib_table.py <corpus_attr_dir> <probe_attr_dir> <pristine_wd>: per moved row / case, the switches
whose single drop changes the law verdict back (toward the pristine verdict).  Pristine verdicts come from
the pristine sweep csvs."""
import csv, sys, os
A, PA, PW = sys.argv[1:4]
SW = ['R11U152_C3_OFF','R11U152_GENLPOPTS_OFF','R11U152_FOLDCHAIN_OFF','R11U152_TPELEMPAT_OFF',
      'R11U152_PKGELEMPAT_OFF','R11U152_ELEMALIAS_OFF','R11U152_TPOVRSTRUCT_OFF','R11U152_GENCASE_OFF',
      'R11U152_DLYREAL_OFF','R11U152_CGINITEND_OFF','R11U152_CLSVARINIT_OFF','R11U152_CLSNESTNAME_OFF',
      'R11U152_CLSPANOFILE_OFF','R11U152_PKGLEAFLOC_OFF']
def load(p, key):
    if not os.path.exists(p): return {}
    return {key(r): (r['status'], r.get('strict', '')) for r in csv.DictReader(open(p))}
ck = lambda r: (r['name'], r['mode'])
for corpus, pre in (('surelog', 'sl'), ('uhdm2rtlil', 'u2')):
    pris = load(f'{PW}/{corpus}.csv', ck)
    law = load(f'{A}/{pre}_NONE.csv', ck)
    print(f'## {corpus}')
    for k in sorted(law):
        if law[k] == pris.get(k): continue
        hits = [s.replace('R11U152_', '').replace('_OFF', '') for s in SW
                if load(f'{A}/{pre}_{s}.csv', ck).get(k) != law[k]]
        print(f'{k[0]},{k[1]}: {pris.get(k)[1] or pris.get(k)[0]} -> {law[k][1] or law[k][0]} | {"+".join(hits) or "?"}')
pk = lambda r: r['case']
pris = load(f'{PW}/probe.csv', pk)
law = load(f'{PA}/p_NONE.csv', pk)
off = load(f'{PA}/p_R11U152_OFF.csv', pk)
print('## probe')
for k in sorted(law):
    if law[k] == pris.get(k): continue
    hits = [s.replace('R11U152_', '').replace('_OFF', '') for s in SW
            if load(f'{PA}/p_{s}.csv', pk).get(k) != law[k]]
    print(f'{k}: {pris[k][1]} -> {law[k][1]} | {"+".join(hits) or "?"} | OFF={"pristine" if off.get(k)==pris.get(k) else off.get(k)}')
