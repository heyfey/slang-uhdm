#!/usr/bin/env python3
"""r10v124 verifier — INDEPENDENT census of every method_func_call declaration
site in a uhdm-dump.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
LHS is ALWAYS golden.

KEY   = <call start line:col>|<call name base>|<prefix start line:col>
        (all three are invariant under the law: the law only shortens a NAME
         and the span END that follows it)
VALUE = name=<VpiName> span=<start-end> pfxkind=<kind> pfxname=<VpiName>
        pfxspan=<start-end> nargs=<n> args=<kind:name,...>
Rows are a MULTISET (Counter), so a colliding key never drops a row.
"""
import sys, re
from collections import Counter

HDR = re.compile(r'\\_([a-z_0-9]+): (.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

def ind(l): return len(l) - len(l.lstrip())

def own(lines, i, field):
    base = ind(lines[i])
    for j in range(i+1, len(lines)):
        l = lines[j]
        if not l.strip(): continue
        if ind(l) <= base: break
        if ind(l) == base+2 and l.lstrip().startswith('|'+field+':'):
            return l.split('|'+field+':',1)[1].strip()
    return ''

def span(l):
    m = LOC.search(l)
    return '%s:%s-%s:%s' % m.groups() if m else '<noloc>'

def kind(l):
    m = HDR.search(l)
    return m.group(1) if m else '?'

def main():
    lines = open(sys.argv[1], errors='replace').read().split('\n')
    rows = Counter()
    for i,l in enumerate(lines):
        if '\\_method_func_call: ' not in l: continue
        k = i-1
        while k >= 0 and not lines[k].strip(): k -= 1
        if k >= 0 and lines[k].lstrip() == '|vpiParent:': continue
        base = ind(l)
        nm = own(lines, i, 'vpiName')
        sp = span(l)
        pfxk = pfxn = pfxs = '-'
        args = []
        j = i+1
        while j < len(lines):
            s = lines[j]
            if s.strip() and ind(s) <= base: break
            if s.strip() and ind(s) == base+2 and s.lstrip() == '|vpiPrefix:':
                pfxk = kind(lines[j+1]); pfxn = own(lines, j+1, 'vpiName'); pfxs = span(lines[j+1])
            if s.strip() and ind(s) == base+2 and s.lstrip() == '|vpiArgument:':
                args.append('%s:%s@%s' % (kind(lines[j+1]), own(lines, j+1, 'vpiName'), span(lines[j+1])))
            j += 1
        key = '%s|%s|%s' % (sp.split('-')[0], nm.split('[')[0], pfxs.split('-')[0])
        val = 'name=%s span=%s pfxkind=%s pfxname=%s pfxspan=%s nargs=%d args=%s' % (
            nm, sp, pfxk, pfxn, pfxs, len(args), ','.join(args))
        rows[(key,val)] += 1
    for k in sorted(rows):
        print('%d\t%s\t%s' % (rows[k], k[0], k[1]))

main()
