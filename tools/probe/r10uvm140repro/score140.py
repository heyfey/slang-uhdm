#!/usr/bin/env python3
# r10uvm140 — score ONE arm directory produced by arm140.sh.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the judge is the official uhdm-cmp.
#
# The law's population: every FUNCTION RETURN whose bound typespec is an
# enum_typespec or a struct_typespec (the two kinds § retNamedTdWinsOverCanon140
# gates on).  A cell is keyed by the function's dumped name; its value is the
# SORTED LIST of typespec names bound across that name's copies, so a
# DEF/ELAB duplicate cannot be silently dropped by a last-writer dict.
#
#   usage: score140.py <armdir> [<view: def|elab>]
# prints  SAME-OK / TOGOLD / MOVED-WRONG / CHANGED-STILL-WRONG / STILL-WRONG
# and an OBJCOUNT line.  WARNING: OBJCOUNT counts how many times the dump
# PRINTS an enum/struct typespec, which is an OCCURRENCE count, not an object
# count -- a re-binding changes which references reach an object and the
# weaklyReferenced tail reorders, so it can legitimately change while nothing
# was minted.  The AWAY test ("a copy where golden shares is AWAY") is
# objcnt140, which counts DISTINCT objects in the Serializer arena.
import sys, os, re, collections

KINDS = ('enum_typespec', 'struct_typespec')

def load(path):
    m = collections.defaultdict(list)
    if not os.path.exists(path):
        return None
    for line in open(path, errors='replace'):
        parts = line.rstrip('\n').split('\t')
        if len(parts) != 3:
            continue
        vk, fn, act = parts
        if not act.startswith(KINDS):
            continue
        m[fn].append(act)
    return {k: sorted(v) for k, v in m.items()}

def objcount(dumppath):
    if not os.path.exists(dumppath):
        return -1
    n = 0
    for line in open(dumppath, errors='replace'):
        s = line.lstrip(' ')
        if s.startswith('\\_enum_typespec:') or s.startswith('\\_struct_typespec:'):
            n += 1
    return n

def main():
    d = sys.argv[1]
    view = sys.argv[2] if len(sys.argv) > 2 else 'def'
    g, o, q = ('g', 'o', 'q') if view == 'def' else ('ge', 'oe', 'qe')
    G, O, Q = (load(os.path.join(d, t + '.ret')) for t in (g, o, q))
    if G is None or O is None:
        print('SKIP\t%s\t%s\tno census' % (d, view)); return
    keys = sorted(set(G) | set(O) | set(Q or {}))
    tally = collections.Counter()
    for k in keys:
        gv, ov = G.get(k), O.get(k)
        qv = Q.get(k) if Q is not None else ov
        if Q is None:
            verdict = 'PRIS-OK' if gv == ov else 'PRIS-WRONG'
        elif gv == ov and gv == qv:
            verdict = 'SAME-OK'
        elif gv != ov and gv == qv:
            verdict = 'TOGOLD'
        elif gv == ov and gv != qv:
            verdict = 'MOVED-WRONG'
        elif qv != ov:
            verdict = 'CHANGED-STILL-WRONG'
        else:
            verdict = 'STILL-WRONG'
        tally[verdict] += 1
        if verdict not in ('SAME-OK', 'PRIS-OK'):
            print('%s\t%s\t%s\tGOLD=%s\tPRIS=%s\tPAT=%s'
                  % (verdict, view, k, gv, ov, qv))
    print('TALLY\t%s\t%s\t%s' % (os.path.basename(d.rstrip('/')), view,
                                 '\t'.join('%s=%d' % kv for kv in sorted(tally.items()))))
    co, cq = objcount(os.path.join(d, o + '.dump')), objcount(os.path.join(d, q + '.dump'))
    print('OBJCOUNT(dump-occurrences)\t%s\t%s\tpris=%d\tpat=%d\t%s'
          % (os.path.basename(d.rstrip('/')), view, co, cq,
             'SAME' if co == cq else 'CHANGED -- confirm with objcnt140'))

main()
