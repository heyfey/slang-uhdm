#!/usr/bin/env python3
"""r10uvm132/score132.py — MEASUREMENT ONLY.  Classifies the CEN132 census rows.

Each row is one BUILT-IN METHOD CALL reaching ExprEmit.cpp's built-in-method
arm.  The columns are the receiver's read, measured at that site:
  raw      what `rawText(recv->sourceRange)` returns (the DEFINITION-site read)
  join     the dotted name rebuilt from the BOUND AST CHAIN
  match    join == raw
  fit      bit0 = the chain's FIRST component starts exactly at the receiver's
           span start; bit1 = its LAST component ends exactly at the receiver's
           span end.  fit==3 is "the chain describes the written receiver".
  chainok  the chain is a pure dotted name (a select/call/scoped name declines)
The law's gate is chainok && !match && fit==3 && both span ends macro-expanded
&& the chain's head is not `this`/`super` (that receiver family belongs to
§ thisStmtHandleCall85's laws and this one refuses it) && sameBuf==1.  The
sameBuf==0 rows of the same shape are § macroSplitRecvIsAstChain128's OWN
population, already rebuilt by that law, and are reported separately.
Usage:  score132.py <cen.tsv> [...]
"""
import collections, sys

def rows(paths):
    for p in paths:
        for l in open(p, errors='replace'):
            if l.startswith('#') or '\t' not in l:
                continue
            test, mode, rest = l.rstrip('\n').split('\t', 2)
            if not rest.startswith('site='):
                continue
            d = {}
            for kv in rest.split('|'):
                if '=' in kv:
                    k, v = kv.split('=', 1)
                    d.setdefault(k, v)
            d['test'], d['mode'] = test, mode
            yield d

KIND = {'8': 'NamedValue', '9': 'HierarchicalValue', '18': 'ElementSelect',
        '19': 'RangeSelect', '20': 'MemberAccess', '21': 'Call',
        '25': 'ArbitrarySymbol'}

def main():
    rs = list(rows(sys.argv[1:]))
    print('TOTAL built-in-method receiver reads: %d' % len(rs))
    print('rows with recv->syntax != null: %d  (the arm NEVER has one)' %
          sum(1 for r in rs if r['syn'] != '0'))
    c = collections.Counter()
    for r in rs:
        macro = 'M' in r['S'].split(' ')[0][-2:]
        c[(r['chainok'], r['match'], r['fit'], KIND.get(r['rk'], r['rk']),
           'macro' if macro else 'file')] += 1
    print('\nchainok match fit kind          where  count')
    for k, v in sorted(c.items(), key=lambda x: -x[1]):
        print('%7s %5s %3s %-13s %-6s %6d' % (k[0], k[1], k[2], k[3], k[4], v))
    def gate0(r):
        return (r['chainok'] == '1' and r['match'] == '0' and r['fit'] == '3'
                and 'M' in r['S'].split(' ')[0][-2:]
                and r['join'].split('.')[0] not in ('this', 'super'))

    def gate(r):
        return gate0(r) and r['sameBuf'] == '1'
    fire = [r for r in rs if gate(r)]
    already128 = [r for r in rs if gate0(r) and r['sameBuf'] == '0']
    print('\n=== ALREADY § macroSplitRecvIsAstChain128 (two-buffer receiver): %d rows'
          % len(already128))
    print('=== THE r10uvm132 LAW GATE (chainok & !match & fit==3 & macro'
          ' & one buffer & not this/super): %d rows' % len(fire))
    g = collections.Counter((r['test'], r['mode']) for r in fire)
    for k, v in sorted(g.items()):
        print('   %-24s %-10s %d' % (k[0], k[1], v))
    print('\n   by site x method x join:')
    g2 = collections.Counter((r['site'].split('orig=')[1].split(' ')[0],
                              r['meth'], r['join'], r['raw']) for r in fire)
    for k, v in sorted(g2.items()):
        print('   %-70s %-11s join=%-16s raw=%-16r %d' % (k[0], k[1], k[2], k[3], v))
    near = [r for r in rs if r['chainok'] == '1' and r['match'] == '0'
            and not gate(r)]
    print('\n=== MISMATCHING BUT OUT OF THE GATE (the negative control): %d rows' % len(near))
    g3 = collections.Counter((r['fit'], 'macro' if 'M' in r['S'].split(' ')[0][-2:] else 'file',
                              r['join'], r['raw'][:40]) for r in near)
    for k, v in sorted(g3.items()):
        print('   fit=%s %-6s join=%-28s raw=%-42r %d' % (k[0], k[1], k[2], k[3], v))
    decl = [r for r in rs if r['chainok'] == '0']
    print('\n=== CHAIN DECLINES (kept pristine): %d rows' % len(decl))
    g4 = collections.Counter(KIND.get(r['rk'], r['rk']) for r in decl)
    for k, v in sorted(g4.items()):
        print('   %-16s %d' % (k, v))

main()
