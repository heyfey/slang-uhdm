#!/usr/bin/env python3
"""probe_strict.py <probe workdir> <out.csv> — the per-case strict column of a
check_probe.py run (which prints only the tally): uhdm-strictcmp on each
case's cached golden and the workdir's database. csv: name,mode,status,detail,blocked_by,strict
(mode 'probe'), so strictdiff.py joins two runs."""
import concurrent.futures, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../scripts'))
import check_probe as cp  # noqa
import verify_golden as vg  # noqa
wd, out = sys.argv[1], sys.argv[2]
def one(rel):
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    o = os.path.join(wd, rel.replace('/', '__') + '.uhdm')
    if not (os.path.exists(g) and os.path.exists(o)):
        return rel, 'MISSING', ''
    return rel, 'CMP_EQUAL', vg.strict_verdict(g, o, 300)
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    res = list(ex.map(one, cp.cases(None)))
with open(out, 'w') as f:
    f.write('name,mode,status,detail,blocked_by,strict\n')
    for rel, st, s in res:
        f.write(f'{rel},probe,{st},,,{s}\n')
print(len(res))
