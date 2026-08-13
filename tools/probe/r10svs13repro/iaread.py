#!/usr/bin/env python3
"""r10svs13 cell reader — the OWN Interfaces() / Interface_arrays() vectors of one
instance object, on both sides, read off the dump's INDENT COLUMN.

Why not grep: every object is REPRINTED inside its own children as a
`vpiParent` back-pointer, and an `interface_array` is reprinted a third time as
the port LowConn ref's `vpiActual`.  A grep over a subtree therefore
over-counts, and a grep for `|vpiInterfaceArray:` cannot say WHICH instance
carries it.  This walks the indent column instead:

  * an object's OWN LISTING is the occurrence of its header with the LARGEST
    subtree (a vpiParent reprint has a subtree of zero or one line);
  * its OWN FIELDS are the `|vpi...` labels at exactly its indent + 2;
  * the element under a label is the `\\_...` line immediately after it.

LHS is ALWAYS golden, RHS is ALWAYS ours — the uhdm-cmp argument order.

usage: iaread.py <g.dump> <o.dump> --obj '<header substring>' [--obj ...]
       iaread.py <g.dump> <o.dump> --census
"""
import sys, re


def load(p):
    return open(p, encoding='utf-8', errors='replace').read().split('\n')


def ind(s):
    return len(s) - len(s.lstrip(' '))


def subtree(L, i):
    """[i, end) of the object whose header is line index i."""
    b = ind(L[i])
    j = i + 1
    while j < len(L):
        s = L[j]
        if s.strip() == '':
            j += 1
            continue
        if ind(s) <= b:
            break
        j += 1
    return j


def own_listing(L, pat):
    """The occurrence of `pat` with the biggest subtree, or None."""
    best = None
    for i, s in enumerate(L):
        t = s.lstrip(' ')
        if not (t.startswith('\\_') or (i == 0)):
            continue
        if pat not in s:
            continue
        e = subtree(L, i)
        if best is None or (e - i) > (best[1] - best[0]):
            best = (i, e)
    return best


FIELD = re.compile(r'^\|(vpi|uhdm)\w+')


def own_fields(L, i, e):
    b = ind(L[i]) + 2
    out = []
    k = i + 1
    while k < e:
        s = L[k]
        if ind(s) == b and FIELD.match(s.lstrip(' ')):
            lab = s.lstrip(' ')
            elem = ''
            if k + 1 < e and ind(L[k + 1]) == b and L[k + 1].lstrip(' ').startswith('\\_'):
                elem = L[k + 1].lstrip(' ')
            out.append((lab, elem))
        k += 1
    return out


def strip_file(s):
    return re.sub(r', file:[^,]*', '', s)


def vecs(L, pat):
    """(found, [interface elems], [interface_array elems], all own labels)"""
    r = own_listing(L, pat)
    if r is None:
        return (False, [], [], [])
    i, e = r
    f = own_fields(L, i, e)
    ifs = [strip_file(el) for lab, el in f if lab.startswith('|vpiInterface:')]
    ias = [strip_file(el) for lab, el in f if lab.startswith('|vpiInterfaceArray:')]
    labs = [lab.rstrip(':') if ':' not in lab[4:] else lab.split(':')[0]
            for lab, _ in f]
    return (True, ifs, ias, labs)


def cell(gl, ol, pat):
    gf, gifs, gias, _ = vecs(gl, pat)
    of, oifs, oias, _ = vecs(ol, pat)
    print(f'  OBJ {pat!r}')
    print(f'    LHS golden : found={gf} Interfaces={len(gifs)} Interface_arrays={len(gias)}')
    for x in gias:
        print(f'                 IA {x}')
    print(f'    RHS ours   : found={of} Interfaces={len(oifs)} Interface_arrays={len(oias)}')
    for x in oias:
        print(f'                 IA {x}')
    if not gf and not of:
        v = 'BOTH-ABSENT'
    elif gf != of:
        v = 'CONTAINER-ONE-SIDED'
    elif len(gifs) == len(oifs) and len(gias) == len(oias):
        v = 'EQ(sizes)'
    else:
        v = 'DIF'
    print(f'    VERDICT {v}   (Interfaces {len(gifs)}/{len(oifs)}, '
          f'Interface_arrays {len(gias)}/{len(oias)})')


def census(gl, ol):
    for nm, L in (('LHS golden', gl), ('RHS ours', ol)):
        lab = sum(1 for s in L if s.lstrip(' ').startswith('|vpiInterfaceArray:'))
        own = []
        for i, s in enumerate(L):
            if '\\_interface_array:' in s and s.lstrip(' ').startswith('\\_'):
                e = subtree(L, i)
                own.append((i + 1, e - i, strip_file(s.strip())))
        big = [x for x in own if x[1] > 1]
        print(f'  {nm}: |vpiInterfaceArray: labels = {lab};  '
              f'\\_interface_array: occurrences = {len(own)};  own listings (subtree>1) = {len(big)}')
        for ln, sz, tx in big:
            print(f'      line {ln} subtree {sz}: {tx}')


def main():
    g, o = sys.argv[1], sys.argv[2]
    gl, ol = load(g), load(o)
    args = sys.argv[3:]
    k = 0
    while k < len(args):
        if args[k] == '--obj':
            cell(gl, ol, args[k + 1])
            k += 2
        elif args[k] == '--census':
            census(gl, ol)
            k += 1
        else:
            print(f'unknown arg {args[k]}')
            sys.exit(2)


main()
