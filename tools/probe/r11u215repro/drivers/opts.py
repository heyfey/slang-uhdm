#!/usr/bin/env python3
# r11u215: the op-level typespec ref of every module-listing param_assign in a judged case dir (g.dump / o.dump from
# case.sh), golden beside ours: its name and whether it has a parent (P) or not (-).  usage: opts.py <case outdir>
import sys,re
def scan(path, section):
    out=[]; on=False; lines=open(path).read().split('\n')
    pa=None
    for i,l in enumerate(lines):
        if l.startswith('|uhdm'):
            on = l.startswith('|'+section+':'); continue
        if not on: continue
        if l.startswith('  \\_param_assign') or l.startswith('  \\_module_inst') : pa=l.strip()
        if l.startswith('      |vpiTypespec:') and lines[i-1].startswith('      |vpiParent') is False:
            # op-level typespec: preceded by the operation's vpiParent block
            ref=lines[i+1].strip(); par = lines[i+2].strip().startswith('|vpiParent')
            out.append((pa, ref, 'P' if par else '-'))
    return out
for sec in ['uhdmtopModules','uhdmallModules']:
    g=scan(sys.argv[1]+'/g.dump',sec); o=scan(sys.argv[1]+'/o.dump',sec)
    print(sec)
    for a,b in zip(g,o):
        flag = '' if a[1:]==b[1:] else '   <== DIFF'
        print('  G', a[0][:40], a[1], a[2], '| O', b[1], b[2], flag)
