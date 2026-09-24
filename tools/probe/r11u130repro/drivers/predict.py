#!/usr/bin/env python3
"""predict.py <pristine sweep workdir> <out.tsv>: from the PRISTINE databases alone, name the row-modes
each r11u130 law can move: run uhdm-strictcmp (all differing objects) golden vs pristine on every
strict-NE CMP_EQUAL row and match each differing record pair against the law's signature
(what the law writes, and the golden value it writes toward). A database outside the union is
predicted NOT to move (modulo the known UVM order coin)."""
import sys, os, csv, glob, re, subprocess, concurrent.futures as cf
S = '/tmp/r11u130_bin/uhdm-strictcmp'
wd, out = sys.argv[1], sys.argv[2]
def golden(rowdir):
    t = open(os.path.join(rowdir, 'cmds.txt')).read()
    m = re.search(r'golden cache hit (\S+?)\)', t)
    if not m: return None
    g = m.group(1)
    return os.path.join(g, 'golden.uhdm') if os.path.isdir(g) else g
def sigs(a, b):
    """a, b: record field lists (depth type name defname fullname file line col endline endcol ...)."""
    out = set()
    if len(a) < 10 or len(b) < 10: return out
    ty = b[1]
    if ty in ('enum_typespec', 'packed_array_typespec') and a[5] and not b[5] and a[6] == '0':
        out.add('DEFNETLOC')
    if ty in ('logic_typespec',) and a[9] != b[9] and a[6] == b[6] and a[7] == b[7]:
        out.add('NETSIGN')
    if ty == 'ref_obj' and a[9] != b[9] and a[6] == b[6] and a[7] == b[7]:
        out.add('WILDSPAN')
    if ty == 'logic_net' and not a[5] and b[5]:
        out.add('CLSARGNET')
    if ty == 'parameter' and a[4] != b[4] and re.fullmatch(r'work@[^.]+\.[^.]+', a[4] or ''):
        out.add('PVPARAM')
    if ty in ('struct_typespec', 'union_typespec') and (a[8], a[9]) != (b[8], b[9]) and a[6] == b[6] and a[7] == b[7]:
        out.add('SUSIGN/IFSUKW')
    if a[6] != b[6] and a[6].isdigit() and b[6].isdigit() and int(b[6]) > int(a[6]) and a[5] == b[5]:
        out.add('REDEFLINE/INCNOTEXT' if ty != 'include_file_info' else 'INCNOTEXT')
    if ty == 'int_typespec' and a[5] != b[5] and a[5] and b[5]:
        out.add('GVTSFILE')
    return out
rows = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for r in csv.reader(open(os.path.join(wd, corpus + '.csv'))):
        if len(r) >= 6 and r[2] == 'CMP_EQUAL' and r[5].startswith('differ'):
            d = glob.glob(os.path.join(wd, corpus, r[1], r[0] + '-*'))
            if d: rows.append((corpus, r[0], r[1], d[0]))
def one(x):
    corpus, name, mode, d = x
    g = golden(d)
    if not g: return x, {'NOGOLDEN'}
    p = subprocess.run([S, '--max', '100000000', g, os.path.join(d, 'slang.uhdm')], capture_output=True, text=True, timeout=1200)
    lines = p.stdout.splitlines(); found = set()
    for i, l in enumerate(lines):
        if l.startswith('  A: ') and i + 1 < len(lines) and lines[i + 1].startswith('  B: '):
            found |= sigs(l[5:].split('\t'), lines[i + 1][5:].split('\t'))
    if 'walk diverged' in p.stdout: found.add('(diverged)')
    return x, found
with cf.ThreadPoolExecutor(3) as ex, open(out, 'w') as f:
    for (corpus, name, mode, d), found in ex.map(one, rows):
        f.write(f'{corpus}\t{name}\t{mode}\t{" ".join(sorted(found))}\n')
