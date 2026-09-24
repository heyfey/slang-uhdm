#!/usr/bin/env python3
"""The FULLNAME family by class. For a fullname-differing paired object, the
identity signature (type name defname file span decompile value) groups every
record of the same source object on one side. gnames = distinct golden full
names in the group, onames = ours. STABLE: golden gives one name at every use
(a parent-link law can match it). USE-SITE: golden gives more names for the
same object than ours has (golden's private copies are named from their use
sites; ours holds fewer objects) - the identity residue: matching it needs a
copy per use. USE-SITE-BOTH: golden names per use and ours has at least as
many distinct names for that object (ours copies too): a per-use parenting law
on our existing objects can match. A row takes the worst class of its objects
(USE-SITE > USE-SITE-BOTH > STABLE). The identity key is analyze.py's anchored
signature (an unlocated record, e.g. every ref_typespec, keys on its nearest
located ancestor). Args: <work dir>."""
import os as _os, sys as _sys
_sys.path.insert(0, _os.path.dirname(_os.path.abspath(__file__)))
from common import rekey
import json, collections, sys
W = sys.argv[1]
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']
for src in ('corpus', 'probe'):
    R = [json.loads(l) for l in open(f'{W}/{src}.jsonl')]
    rowcls = {}; shape = collections.defaultdict(collections.Counter); shaperows = collections.defaultdict(lambda: collections.defaultdict(set))
    ocopy = collections.Counter()
    first_fn = 0; first_cls = collections.Counter()
    for r in R:
        k = (r['corpus'], r['mode'], r['test'])
        fx = [x for x in r['rows'] if x['facet'] == 'fullname']
        if not fx: continue
        cls = set()
        for x in fx:
            if x['gnames'] <= 1: c = 'STABLE'
            elif x['onames'] < x['gnames']: c = 'USE-SITE'
            else: c = 'USE-SITE-BOTH'
            cls.add(c); shape[rekey(x)][c] += 1; shaperows[rekey(x)][c].add(k)
        rc = 'USE-SITE' if 'USE-SITE' in cls else ('USE-SITE-BOTH' if 'USE-SITE-BOTH' in cls else 'STABLE')
        rowcls[k] = rc
        if r['strict'].startswith('differ:fullname') or (src == 'probe'):
            pass
    tot = collections.Counter(rowcls.values())
    print(f'== {src}: row-modes with a fullname facet {len(rowcls)}: ' + ' '.join(f'{a}={b}' for a, b in tot.items()))
    if src == 'corpus':
        # rows whose ONLY remaining facets are fullname ones, by class
        only = collections.Counter()
        for r in R:
            k = (r['corpus'], r['mode'], r['test'])
            if k in rowcls and all(x['facet'] == 'fullname' for x in r['rows']): only[rowcls[k]] += 1
        print('   rows whose every facet is fullname:', dict(only))
        ffc = collections.Counter(rowcls[(r['corpus'], r['mode'], r['test'])] for r in R
                                  if r['strict'].startswith('differ:fullname') and (r['corpus'], r['mode'], r['test']) in rowcls)
        print('   rows whose FIRST field is fullname:', sum(1 for r in R if r['strict'].startswith('differ:fullname')), dict(ffc))
        tests = collections.defaultdict(set)
        for k, v in rowcls.items(): tests[v].add((k[0], k[2]))
        print('   tests:', {a: len(b) for a, b in tests.items()}, ' surelog/u2r USE-SITE rows:',
              sum(1 for k, v in rowcls.items() if v == 'USE-SITE' and k[0] == 'surelog'),
              sum(1 for k, v in rowcls.items() if v == 'USE-SITE' and k[0] == 'uhdm2rtlil'))
    print('   shapes (top 40 by rows): cluster rows STABLE USE-SITE USE-SITE-BOTH (objects) | rows-with-USE-SITE key')
    rows_by = sorted(shape, key=lambda c: -len(set().union(*shaperows[c].values())))
    for c in rows_by[:40]:
        allr = set().union(*shaperows[c].values())
        print('  ', cid.get(c, '?'), len(allr), shape[c]['STABLE'], shape[c]['USE-SITE'], shape[c]['USE-SITE-BOTH'], '|', len(shaperows[c]['USE-SITE']), c)
    json.dump({'|'.join(k): v for k, v in rowcls.items()}, open(f'{W}/fnclass_{src}.json', 'w'))
