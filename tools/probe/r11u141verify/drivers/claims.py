#!/usr/bin/env python3
"""claims.py -> /tmp/r11u141_claims.tsv : pass, corpus, key of every conversion the three pass READMEs' evidence claims"""
import csv, re
T='/home/heyfey/git-repos/slang-uhdm/tools/probe'
names={c:{r['name'] for r in csv.DictReader(open(f'/tmp/r11u141_wdON/{c}.csv'))} for c in ('surelog','uhdm2rtlil')}
out=[]
for l in open(f'{T}/r11u130repro/evidence/cols_P_L.tsv'):
    f=l.rstrip('\n').split('\t')
    if f[0]=='turned':
        n,m=f[1].split(','); cs=[c for c in names if n in names[c]]
        for c in cs: out.append(('130',c,f'{n},{m}'))
for l in open(f'{T}/r11u130repro/evidence/probe_P_L.tsv'):
    f=l.rstrip('\n').split('\t')
    if f[0]=='turned': out.append(('130','probe',f[1]))
for c,fn in (('surelog','strictdiff_surelog'),('uhdm2rtlil','strictdiff_uhdm2rtlil'),('probe','strictdiff_probe')):
    for l in open(f'{T}/r11u131repro/evidence/{fn}.txt'):
        f=l.rstrip('\n').split('\t')
        if f[0]=='TO-EQUAL':
            k=f[1]
            if c=='probe': k=re.sub(r'/probe$','',k)
            else: k=k.replace('/',',')
            out.append(('131',c,k))
for l in open(f'{T}/r11u134repro/evidence/cols_P_L.tsv'):
    f=l.rstrip('\n').split('\t')
    if len(f)>4 and f[4]=='TURNED_EQUAL':
        k=f[1] if f[0]=='probe' else f[1].replace('/',',')
        out.append(('134',f[0],k))
with open('/tmp/r11u141_claims.tsv','w') as fo:
    for o in out: fo.write('\t'.join(o)+'\n')
import collections; print(collections.Counter((a,b) for a,b,_ in out))
