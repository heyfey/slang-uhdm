#!/usr/bin/env python3
"""v11u224: walkprefix.py <case-view dir under $S/g> : the index of the first walk record (variant comparator's
records, raw full name, as caseaway.py writes them to .g/.P/.L.xrec) where P and L leave golden.  A larger index
for L = the law's walk agrees with golden further (toward); used on stage-1 case-views where the strict walk is not
reported by uhdm-strictcmp.  Run caseaway.py on the dir first."""
import sys
d = sys.argv[1]
def recs(t):
    out = []
    for l in open(f'{d}/.{t}.xrec', errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw; out.append('|'.join(f))
    return out
G, P, L = recs('g'), recs('P'), recs('L')
def first(a):
    for i, (x, y) in enumerate(zip(G, a)):
        if x != y: return i + 1
    return min(len(G), len(a)) + 1
print(f'{d.split("/g/")[-1]} records g/P/L={len(G)}/{len(P)}/{len(L)} firstdiff P=#{first(P)} L=#{first(L)}')
