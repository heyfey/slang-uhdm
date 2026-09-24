#!/usr/bin/env python3
"""table.py <run.jsonl> [mode]: per case: at base (law on), law off, judge off->on (walk-aligned), judge2 (difflib-aligned),
the three landings off, judge A3->on, extra switches, dump delta for stage-1 byte moves. TSV to stdout."""
import sys, json, subprocess, os, re
H=os.path.dirname(os.path.abspath(__file__)); CW='/tmp/r11u143_cases'
def run(s,*a): return subprocess.run(['python3',f'{H}/{s}']+list(a),capture_output=True,text=True).stdout.strip()
def st(x):
    if not x or x.get('md5') is None: return f"rc={x.get('rc') if x else '?'} nodb"
    s=x.get('strict','')
    if s.startswith('STRICT_EQUAL'): return 'equal'
    if 'stage1' in s or x.get('cmp'): return f"stage1 cmp={x.get('cmp')}"
    f=x.get('fields','')
    m=re.search(r'objects_differing=(\d+)',f)
    return 'ne:'+s.split()[-1]+'(%s)'%(m.group(1) if m else '?')
def jv(k,P,L):
    v=run('judge.py',f'{CW}/{k}',P,L)
    if v.startswith('STAGE1-both'):
        v='STAGE1-both '+run('dd.py',f'{CW}/{k}',P,L)
    elif v not in ('SAME',) and not v.startswith('NODB'):
        v=v+' || '+run('judge2.py',f'{CW}/{k}',P,L)
    return v
mode=sys.argv[2] if len(sys.argv)>2 else 'default'
for line in open(sys.argv[1]):
    r=json.loads(line); name='/'.join(r['case'].split('/')[-2:])
    if not r.get('golden'): print('\t'.join([name,mode,r['law'],'NOGOLDEN',st(r.get('ON')),'','','','',''])); continue
    k=r['key']
    ex=[f"{c}:{jv(k,c,'ON').split(' P=')[0]}" for c in r if c.startswith('X_')]
    print('\t'.join([name,mode,r['law'],st(r['ON']),st(r['OFF']),jv(k,'OFF','ON'),st(r['A3']),jv(k,'A3','ON'),';'.join(ex)]))
