#!/usr/bin/env python3
"""r11u106 A-PRIORI MOVER CENSUS for § structPatternOpTsBoundFold106 (S) and
§ typedefArrayVarElabFold106 (M), keyed on the DATABASES, golden first.

For every sweep row that has BOTH databases, tw106 (the range-bound walker)
reads golden and ours by NAME key (the path of container / home / member names
+ range index + side).  A cell is IN REACH when OUR bound sits where a law
writes and is a shape the law folds:
  S: under an ELAB param_assign's pattern OPERATION's own typespec
     (`/pa(<p>).rhs/operation@..ts/struct_typespec`, members only, no /elem/,
     no nested pattern op) and the bound is an operation or `$clog2`;
  M: the top-level range of an ELAB variable's array_typespec
     (`Top/.../var(<v>)/array_typespec`, no /elem/) and the bound is an
     operation.
Each reach cell is classed against golden's cell under the SAME key:
  GOLD-FOLD  golden is a location-less INT/UINT size-64 constant  (the law's face)
  GOLD-OTHER golden is something else (the law would move it AWAY or WRONG)
  NO-GOLD    golden has no cell under the key.
It is a superset of the gates (ownership, the variable/net split and the
package home are not visible to a name key): the law SWEEP is the arbiter.
usage: census106.py <sweep workdir> [...]        one line per reach cell + totals
       census106.py --gg <sweep workdir> [...]   golden read as BOTH sides (calibration)
       census106.py --pair <g.uhdm> <o.uhdm>     one arm (the positive control)
"""
import collections, os, re, subprocess, sys
TW = os.environ.get('TW106', '/tmp/r11u106_tw')
S_RE = re.compile(r'^Top/.*/pa\([^)]*\)\.rhs/operation7[56]@[^/]*\.ts/struct_typespec[^/]*'
                  r'(/m:[^/]+/(struct_typespec|logic_typespec|packed_array_typespec)[^/]*)+/range\d+@')
M_RE = re.compile(r'^Top/.*/var\([^)]*\)/array_typespec[^/]*/range\d+@[^/]*$')

def tw(u):
    try:
        r = subprocess.run([TW, u], capture_output=True, text=True, timeout=900)
    except subprocess.TimeoutExpired:
        return None
    d = collections.defaultdict(list)
    for l in r.stdout.splitlines():
        if l.count('\t') < 2:
            continue
        path, side, val = l.split('\t', 2)
        path = re.sub(r'#\d+', '', path)
        d[path + '\t' + side].append(re.sub(r'\s*#\d+$', '', val.strip()))
    return d

def law_shape(path, val):
    if M_RE.search(path) and '/elem/' not in path:
        return 'M' if val.startswith('operation ') else None
    if S_RE.search(path) and '/elem/' not in path and '/op75.' not in path and '/op76.' not in path:
        if val.startswith('operation ') or val.startswith('sys_func_call:$clog2'):
            return 'S'
    return None

def gold_fold(v):
    return bool(re.match(r'constant U?INT:-?\d+ sz64 ct(7|9) dc=-?\d+ @-$', v))

def pair(g, o):
    G, O = tw(g), tw(o)
    if G is None or O is None:
        return None
    out = []
    for k, vs in O.items():
        path = k.split('\t')[0]
        for i, v in enumerate(vs):
            law = law_shape(path, v)
            if not law:
                continue
            gv = G.get(k)
            if not gv:
                cls = 'NO-GOLD'
            else:
                g1 = gv[i] if i < len(gv) else gv[-1]
                cls = 'GOLD-FOLD' if gold_fold(g1) else 'GOLD-OTHER'
                v = v + ' || gold=' + g1
            out.append((law, cls, k.replace('\t', ' '), v))
    return out

def rows(wd):
    for root, dirs, files in os.walk(wd):
        if 'slang.uhdm' in files and 'cmds.txt' in files:
            m = re.search(r'cache hit (\S+)\)', open(os.path.join(root, 'cmds.txt')).read())
            if not m:
                continue
            g = os.path.join(m.group(1), 'golden.uhdm')
            if os.path.isfile(g):
                yield root, g, os.path.join(root, 'slang.uhdm')

def main(a):
    if a and a[0] == '--pair':
        for c in pair(a[1], a[2]) or []:
            print('CELL', *c, sep='\t')
        return
    gg = a and a[0] == '--gg'
    if gg:
        a = a[1:]
    tot = collections.Counter(); rowset = collections.defaultdict(set); n = 0
    for wd in a:
        for root, g, o in rows(wd):
            n += 1
            res = pair(g, g if gg else o)
            if res is None:
                print('TIMEOUT', root); continue
            row = '/'.join(root.rstrip('/').split('/')[-2:])
            for law, cls, k, v in res:
                tot[(law, cls)] += 1
                rowset[(law, cls)].add(row)
                print('CELL', row, law, cls, k, v, sep='\t')
    print('DATABASES', n)
    for key in sorted(tot):
        print('TOTAL', *key, 'cells=%d' % tot[key], 'rowdbs=%d' % len(rowset[key]), sep='\t')

main(sys.argv[1:])
