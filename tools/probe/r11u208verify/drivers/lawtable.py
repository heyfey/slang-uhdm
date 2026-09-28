#!/usr/bin/env python3
# (r11u208) lawtable.py <grid_def.txt> <grid_el.txt>: per law of drivers/laws.py, the grid's verdicts (grid.py RESULT
# lines: the law switched off alone = pristine for that law, against the law binary) over both views: fired
# case-views, the verdict tally and the case-views per verdict.  Verdicts: TOWARD (strict records toward golden, none
# away), STAGE1-CLOSER (stage-1 differs at both; the order-blind dump distance to golden falls, no new bad line),
# STAGE1-SAME (the distance is unchanged), UNMASK (a divergence removed exposes records behind it), MIXED (records
# toward and records away), BYTES-ONLY (bytes move, no record), UNFIRED (the trace names no firing).
import sys, re, collections, importlib.util, os
spec = importlib.util.spec_from_file_location('laws', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'laws.py'))
laws = importlib.util.module_from_spec(spec); spec.loader.exec_module(laws)
res = collections.defaultdict(lambda: collections.defaultdict(list)); fired = collections.defaultdict(set)
for f in sys.argv[1:]:
    for l in open(f):
        m = re.match(r'RESULT (\S+) (\S+) (\S+)', l)
        if not m: continue
        case, law, v = m.groups()
        law = law.split(':')[0]
        if law in laws.SW:
            res[law][v].append(case)
            if v != 'UNFIRED': fired[law].add(case)
for law in laws.SW:
    t = res.get(law, {})
    tally = ' '.join(f'{v}={len(c)}' for v, c in sorted(t.items()) if v != 'UNFIRED')
    print(f"{law} [{' '.join(laws.SW[law])}] fired_case_views={len(fired[law])} {tally or 'NONE'}")
    for v, c in sorted(t.items()):
        if v in ('UNFIRED',): continue
        print(f'    {v}: ' + ' '.join(sorted(set(c))))
