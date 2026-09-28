#!/usr/bin/env python3
"""r11u196: the prediction check.  Joins the byte movers (byteverify MOVER lines, `./<corpus>/<mode>/<row>-<h>/slang.uhdm`)
with the firing census (censum.py output, frozen before the law sweep) and the pristine-database predictor (predict.sh
output, frozen before the law sweep).  usage: predcheck.py <byteverify.txt> <census.txt> <predict.txt>"""
import re, sys, collections
bv, cen, pre = sys.argv[1:4]
movers = set()
for l in open(bv):
    m = re.match(r'MOVER \./(surelog|uhdm2rtlil)/(default|testflags)/(.+)-[0-9a-f]{8}/slang\.uhdm', l)
    if m: movers.add('%s/%s/%s' % m.groups())
census = {}
for l in open(cen):
    k, *laws = l.split()
    if not k.startswith('probe/'): census[k] = laws
pred = {}
for l in open(pre):
    f = l.split()
    if len(f) >= 3 and f[0] in ('surelog', 'uhdm2rtlil'): pred['%s/%s/%s' % (f[0], f[1], f[2])] = f[3:]
print('movers', len(movers), 'census-named', len(census), 'predictor-named', len(pred))
mnp = sorted(movers - set(census))
print('MOVED_NOT_IN_CENSUS', len(mnp), ' '.join(mnp))
pnm = sorted(set(census) - movers)
print('CENSUS_NOT_MOVED', len(pnm), ' '.join('%s[%s]' % (k, ','.join(census[k])) for k in pnm))
# the r11u196 laws: every mover whose census names an r11u196 law must be named by the pristine-db predictor
laws196 = {'modGenericClassListed196':'MODGEN','modGenericHandleBare196':'MODGEN','modClassTsLinksDefListing196':'MODGEN',
           'classPropElemClassTsAtName196':'ELEMCLS','retPkgQualTdNoAlias196':'RETQUAL','tpArrBoundAtLeftOperand196':'TPARR',
           'evalFuncOmittedDefaultKeepsCall196':'DFLTARG','tfFormalTdCloneFile196':'FCFILE'}
miss = []
for k in sorted(movers & set(census)):
    for lw in census[k]:
        n = lw.split('=')[0]
        if n in laws196 and laws196[n] not in pred.get(k, []): miss.append('%s:%s' % (k, n))
print('R196_FIRING_MOVERS_NOT_PREDICTED_FROM_PRISTINE', len(miss), ' '.join(miss))
bylaw = collections.Counter()
for k in movers & set(census):
    for lw in census[k]: bylaw[lw.split('=')[0]] += 1
print('movers per firing law:', ', '.join('%s %d' % kv for kv in sorted(bylaw.items())))
alone = collections.Counter()
for k in movers & set(census):
    if len(census[k]) == 1: alone[census[k][0].split('=')[0]] += 1
print('movers by one law alone:', ', '.join('%s %d' % kv for kv in sorted(alone.items())))
