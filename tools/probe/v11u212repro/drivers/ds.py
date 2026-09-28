#!/usr/bin/env python3
# v11u212: downstream verdict via the gate's own one(); SLANG_UHDM=<bin> GOLDEN_CACHE=<dir> ds.py <workroot> <casedir>...
import sys, os, re
REPO=os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, REPO + '/scripts')
F=None
for l in open(REPO+'/tools/probe/r11u107repro/canaudit.sh'):
    if l.startswith('FENCED='): F=re.sub(r'["\']','',l[len('FENCED='):]).split()
assert F and len(F)==4, 'fence unreadable'
import downstream_uhdm2rtlil as ds
wr=sys.argv[1]
for c in sys.argv[2:]:
    c=os.path.abspath(c)
    assert not any(re.search(r'(?<![A-Za-z0-9_])'+re.escape(x)+r'(?![A-Za-z0-9_])',c) for x in F),'fenced'
    name=c.split('/cases/')[-1].replace('/','_')
    files=open(c+'/args').read().split() if os.path.exists(c+'/args') else ['dut.sv']
    r=ds.one(name,c,['-parse','-nobuiltin','-nocache','-sv']+files,wr,300)
    print(name,r.get('verdict'),r.get('surelog_status'),r.get('slang_status'),'differs='+str(r.get('differs')),flush=True)
