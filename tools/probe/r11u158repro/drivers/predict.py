#!/usr/bin/env python3
"""predict.py <census dir> <out tsv>: the predicted mover set, BY NAME, from the firing census
(census.sh): one line per corpus row-mode (surelog/uhdm2rtlil, mode, name) or probe case with the
laws that fired on it.  Fail-closed on $FENCED: refuses without the four names; a fenced name in the
census is an error (the census never dispatches one)."""
import os, re, sys, collections
fenced = os.environ.get('FENCED', '').split()
if len(fenced) != 4:
    sys.exit('predict.py: export FENCED (four names) first')
cen, out = sys.argv[1], sys.argv[2]
pred = collections.defaultdict(set)
for corpus, f in (('surelog', 'census_surelog.log'), ('uhdm2rtlil', 'census_u2r.log'), ('probe', 'census_probe.log')):
    for line in open(os.path.join(cen, f)):
        p = line.split()
        path, law = p[0], ' '.join(p[2:])
        law = re.sub(r'^R11U158_TRACE ', '', law)
        law = re.sub(r'^R11U157 (route|law) ', '157:', law)
        if corpus == 'probe':
            key = ('probe', '', os.path.basename(path)[:-5].replace('__', '/'))
        else:
            m = re.search(r'/(default|testflags)/(.+)-[0-9a-f]{8}/slang\.uhdm$', path)
            key = (corpus, m.group(1), m.group(2))
            if key[2] in fenced:
                sys.exit('fenced name in census: refusing')
        pred[key].add(law.split()[0] if law.startswith('157:route') is False else law)
with open(out, 'w') as o:
    for k in sorted(pred):
        o.write('\t'.join(k) + '\t' + ','.join(sorted(pred[k])) + '\n')
print(len(pred), 'predicted', collections.Counter(k[0] for k in pred))
