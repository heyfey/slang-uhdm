#!/usr/bin/env python3
# predict.py <pristine wd>  -> rows (corpus/mode/name) whose golden-vs-pristine strict records carry a face
# one of the r11u134 laws writes: a ref_typespec/ref_obj full name, a struct/union/enum typespec span or file,
# a range constant without a file, a union_typespec without a location, an alias ref where golden lists a range.
import sys, os, re, glob, subprocess, csv
sys.path.insert(0, '/tmp/wt_r11u134/scripts')
SC = '/tmp/r11u134_bin/uhdm-strictcmp'
P = sys.argv[1]
def golden_of_rowdir(d):
    t = open(os.path.join(d, 'cmds.txt')).read()
    m = re.search(r'golden cache hit (\S+?)\)', t) or re.search(r'golden cache hit (\S+)', t)
    g = m.group(1) if m else None
    if g and os.path.isdir(g):
        gg = glob.glob(os.path.join(g, '*.uhdm')); g = gg[0] if gg else None
    return g
sig = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for r in csv.reader(open(f'{P}/{corpus}.csv')):
        if r[0] == 'name' or r[2] != 'STRICT_NOTEQUAL': continue
        name, mode = r[0], r[1]
        d = glob.glob(f'{P}/{corpus}/{mode}/{name}-*')
        if not d: continue
        g = golden_of_rowdir(d[0])
        if not g: continue
        out = subprocess.run([SC, '--max', '100000', g, d[0] + '/slang.uhdm'], capture_output=True, text=True, timeout=900).stdout
        faces = set()
        lines = out.splitlines()
        for i, l in enumerate(lines):
            m = re.match(r'#\d+ (\w+)', l)
            if not m or i + 2 >= len(lines): continue
            f = m.group(1); A = lines[i+1].split('\t'); B = lines[i+2].split('\t')
            ta = A[1] if len(A) > 1 else ''; tb = B[1] if len(B) > 1 else ''
            if f == 'fullname' and ta in ('ref_typespec', 'ref_obj'): faces.add('name:' + ta)
            if f in ('endline', 'endcol', 'file', 'line', 'col') and ta in ('struct_typespec', 'union_typespec', 'enum_typespec', 'logic_typespec'): faces.add('span:' + ta)
            if f in ('file', 'line', 'col') and ta == 'constant': faces.add('span:constant')
            if f == 'type' and tb == 'ref_typespec': faces.add('alias')
        if faces:
            sig.append((corpus, mode, name, ' '.join(sorted(faces))))
for s in sig: print('\t'.join(s))
