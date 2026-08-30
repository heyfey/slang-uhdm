#!/usr/bin/env python3
"""r10earl101 -- MEASUREMENT ONLY.  The corpus census driver + scorer.

Runs ct101cen over every (golden, ours) pair in a verify_golden workdir and
scores, per database, the SIG multiset (never a last-writer dict -- keys
collide).  The FILE is stripped from every payload before the join: our
databases carry an empty VpiFile on some objects and no generated Compare
reads VpiFile.

It also reports THE LAW'S OWN POPULATION separately: every cell reached as
`<site> ... ts>e` (or deeper) whose payload is a SCALAR typespec kind
(logic/bit/int/integer/...) with a package vpiInstance -- i.e. every packed-
vector binding of a package SCALAR typedef, keyed by view and site.  That is
the denominator the law could possibly touch; the AGGREGATE kinds (struct,
enum, union) are outside it by construction.

  cen101.py <workdir> [out.txt] [--pop-only]
"""
import os, sys, subprocess, collections

CEN = os.environ.get('CT101CEN', '/tmp/r10earl101_cen')
SCALAR = ('logic_typespec', 'bit_typespec', 'int_typespec', 'integer_typespec',
          'byte_typespec', 'short_int_typespec', 'long_int_typespec',
          'time_typespec', 'real_typespec', 'shortreal_typespec')


def strip_file(payload):
    bits = payload.split('|')
    if len(bits) == 4 and ':' in bits[3]:
        bits[3] = bits[3].split(':', 1)[1]
    return '|'.join(bits)


def run(db):
    p = subprocess.run([CEN, db], capture_output=True, text=True, timeout=1800)
    if p.returncode != 0:
        return None
    sig = collections.Counter()
    for line in p.stdout.splitlines():
        if not line.startswith('SIG\t'):
            continue
        parts = line.split('\t')
        if len(parts) != 8:
            continue
        _, view, okind, ofull, site, name, path, payload = parts
        sig[(view, okind, ofull, site, name, path, strip_file(payload))] += 1
    return sig


def population(sig):
    """The law's own shape: an ELEMENT link (path contains '>e') whose payload
    is a SCALAR kind with a package vpiInstance.  Keyed view|site|BARE/QUAL."""
    pop = collections.Counter()
    for k, c in sig.items():
        view, okind, ofull, site, name, path, payload = k
        if '>e' not in path:
            continue
        bits = payload.split('|')
        if len(bits) < 3 or bits[0] not in SCALAR:
            continue
        if not bits[2].startswith('package['):
            continue
        shape = 'QUAL' if '::' in bits[1] else 'BARE'
        pop[(view, site, shape)] += c
    return pop


def golden_of(work):
    cf = os.path.join(work, 'cmds.txt')
    if not os.path.exists(cf):
        return None
    for line in open(cf):
        if 'golden cache hit' in line:
            return os.path.join(line.split('golden cache hit ')[1].strip().rstrip(')'), 'golden.uhdm')
    return None


def pairs(workroot):
    for mode in sorted(os.listdir(workroot)):
        md = os.path.join(workroot, mode)
        if not os.path.isdir(md):
            continue
        for d in sorted(os.listdir(md)):
            w = os.path.join(md, d)
            ours = os.path.join(w, 'slang.uhdm')
            g = golden_of(w)
            if g and os.path.exists(g) and os.path.exists(ours):
                yield mode, d, g, ours


def main():
    workroot = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else '-'
    fh = sys.stdout if out == '-' else open(out, 'wt')
    tot = collections.Counter()
    gpop = collections.Counter()
    opop = collections.Counter()
    ndb = 0
    for mode, name, g, o in pairs(workroot):
        try:
            gs = run(g)
            os_ = run(o)
        except Exception as e:
            print('ERR', mode, name, e, file=fh)
            continue
        if gs is None or os_ is None:
            print('RESTORE_FAIL', mode, name, file=fh)
            continue
        ndb += 1
        only_g = gs - os_
        only_o = os_ - gs
        same = sum((gs & os_).values())
        tot['BOTH-SAME'] += same
        tot['ONLY-GOLDEN'] += sum(only_g.values())
        tot['ONLY-OURS'] += sum(only_o.values())
        gp = population(gs); op = population(os_)
        gpop.update(gp); opop.update(op)
        if os.environ.get('POPROW'):
            for k, c in sorted(gs.items()):
                if '>e' in k[5]:
                    b = k[6].split('|')
                    if b[0] in SCALAR and len(b) > 2 and b[2].startswith('package['):
                        print(f'POPROW\tG\t{mode}/{name}\t' + '\t'.join(k), file=fh)
            for k, c in sorted(os_.items()):
                if '>e' in k[5]:
                    b = k[6].split('|')
                    if b[0] in SCALAR and len(b) > 2 and b[2].startswith('package['):
                        print(f'POPROW\tO\t{mode}/{name}\t' + '\t'.join(k), file=fh)
        # the law's shape, one-sided, printed per database
        gk = collections.Counter({k[:6]: c for k, c in only_g.items()})
        ok = collections.Counter({k[:6]: c for k, c in only_o.items()})
        shared = gk & ok
        for k, c in sorted(only_g.items()):
            if k[:6] in shared and '>e' in k[5]:
                print(f'G-ONLY\t{mode}/{name}\t' + '\t'.join(k), file=fh)
        for k, c in sorted(only_o.items()):
            if k[:6] in shared and '>e' in k[5]:
                print(f'O-ONLY\t{mode}/{name}\t' + '\t'.join(k), file=fh)
    print(f'DATABASES {ndb}', file=fh)
    for k in ('BOTH-SAME', 'ONLY-GOLDEN', 'ONLY-OURS'):
        print(f'{k} {tot[k]}', file=fh)
    print('POPULATION (element link, scalar kind, package instance)', file=fh)
    for k in sorted(set(gpop) | set(opop)):
        print(f'  POP {"|".join(k)}  golden={gpop[k]}  ours={opop[k]}', file=fh)
    fh.flush()


if __name__ == '__main__':
    main()
