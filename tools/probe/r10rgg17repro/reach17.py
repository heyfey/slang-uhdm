#!/usr/bin/env python3
"""r10rgg17repro/reach17.py — the INSTRUMENT'S REACH, so that a `predicted=0`
is read as a MEASUREMENT and not as an instrument that reached nothing.
Counts, per corpus workdir: databases carrying ANY port-parented `hier_path`,
the total number of them, and how many carry the pass's exact object shape
(a bracketed `ref_obj` FIRST element).
  usage: reach17.py <workdir> <out.txt>
"""
import os, subprocess, sys, re
CEN='/tmp/r10rgg17_hpcensus'
def main():
    wd,outp=sys.argv[1],sys.argv[2]
    dbs=0; withhp=0; tot=0; shape=0; rows=[]
    for mode in sorted(os.listdir(wd)):
        mdir=os.path.join(wd,mode)
        if not os.path.isdir(mdir): continue
        for d in sorted(os.listdir(mdir)):
            db=os.path.join(mdir,d,'slang.uhdm')
            if not os.path.isfile(db): continue
            dbs+=1
            out=subprocess.run([CEN,db,'O'],capture_output=True,text=True).stdout
            n=0; sh=0
            for ln in out.split('\n'):
                if 'PAR=port:' not in ln or '\t||\t' not in ln: continue
                n+=1
                m=re.search(r'\tE0=ref_obj\|R\{([^}]*)\}',ln)
                if m and '[' in m.group(1): sh+=1
            if n: withhp+=1; tot+=n; rows.append((mode,d,n,sh))
            shape+=sh
    with open(outp,'wt') as f:
        f.write('databases=%d with_port_hier_path=%d port_hier_paths=%d bracketed_ref_obj_elem0=%d\n'%(dbs,withhp,tot,shape))
        for r in rows: f.write('%s\t%s\t%d\t%d\n'%r)
    print('databases=%d with_port_hier_path=%d port_hier_paths=%d bracketed_ref_obj_elem0=%d'%(dbs,withhp,tot,shape))
main()
