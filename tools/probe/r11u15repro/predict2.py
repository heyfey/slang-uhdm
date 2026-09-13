#!/usr/bin/env python3
"""r11u15 LAW-2 a-priori mover predictor, from PRISTINE databases only.

§ wholeWriteIsNotTheDiscriminatorForANET drops the whole-write carve-out for a
reference whose actual is a NET.  The only cells it can move are, exactly:

    a ref_obj whose vpiActual is a NETS-class object, whose vpiFullName is
    also carried by a PLAIN `part_select` (vpiConstantSelect, constant left
    range) in the same database -- i.e. a whole reference the old carve-out
    held on the net while a same-name plain part-select existed.

Read off the pristine dump; a database with no such pair cannot move.
usage: predict2.py <workdir>...
"""
import os, re, sys, subprocess, concurrent.futures
DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
NETK = ('logic_net','array_net','struct_net','enum_net','packed_array_net',
        'net_bit','integer_net','time_net','bit_net','byte_net','short_int_net',
        'int_net','long_int_net')

def scan(txt):
    L = txt.split('\n')
    psel = set()
    for i, ln in enumerate(L):
        m = re.search(r'\\_part_select: \S* \((.*?)\)', ln)
        if m:
            psel.add(m.group(1))
    hits = []
    for i, ln in enumerate(L):
        m = re.search(r'\\_ref_obj: \((.*?)\)', ln)
        if not m or m.group(1) not in psel:
            continue
        ind = len(ln) - len(ln.lstrip())
        j = i + 1
        while j < len(L):
            s = L[j]; k = len(s) - len(s.lstrip())
            if k <= ind: break
            if s.strip() == '|vpiActual:':
                a = L[j+1].strip()
                mm = re.match(r'\\_(\w+):', a)
                if mm and mm.group(1) in NETK:
                    hits.append((m.group(1), mm.group(1)))
                break
            j += 1
    return hits

def one(p):
    try:
        return (p, scan(subprocess.run([DUMP,p],capture_output=True,text=True,
                                       timeout=1200).stdout), None)
    except Exception as e:
        return (p, None, str(e))

dbs=[]
for wd in sys.argv[1:]:
    for r,_,fs in os.walk(wd):
        for f in fs:
            if f.endswith('.uhdm'): dbs.append(os.path.join(r,f))
dbs.sort()
print(f"# databases: {len(dbs)}", file=sys.stderr)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
    for p,h,err in ex.map(one,dbs):
        if err: print(f"ERR {p} {err}", file=sys.stderr); continue
        if h: print(f"{len(h)}\t{p}\t{sorted(set(h))[:4]}")
