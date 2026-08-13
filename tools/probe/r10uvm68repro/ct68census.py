#!/usr/bin/env python3
"""r10uvm68 — THE SPAN-KEYED CENSUS OF ONE SIDE, the brief's first instruction.

  usage: ct68census.py <dump> [--list KIND] [--ts]

Three tables, and they answer three different questions:

  VARS  (default)  every VARIABLE kind x whether its typespec is NAMED (reached
                   through a typedef / a type parameter) or ANON (written at the
                   declaration) x whether the object carries `vpiSigned`.  This
                   is the table that decides this pass's law: run it on GOLDEN
                   and on OURS and read the cell that disagrees.
  --list KIND      every individual object of KIND whose typespec is NAMED, with
                   its signedness, dump line, span, typespec and parent kind —
                   so the population behind a count can be inspected instead of
                   trusted.
  --ts             the same NAMED/ANON x signed table for TYPESPEC objects.  It
                   exists because the two carriers of signedness on ONE
                   declaration DISAGREE (§ atomVarSignedWritten68): the variable
                   keys on the type AS WRITTEN, the typespec on the RESOLVED
                   type.

CONVENTION: LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.  This script
reads ONE side, so the CALLER states which; nothing here guesses.

TRAPS ENCODED:
  * uhdm-dump's FIRST LINE is the database path -> callers pass `sed 1d` dumps.
  * AN OBJECT IS NOT A DUMP OCCURRENCE.  The same object is printed once with
    its children and again, CHILDLESSLY, wherever it is referenced.  A childless
    print carries NO fields, so counting it would report `vpiSigned absent` for
    every object in the database.  Back-references are dropped, and the object
    is keyed on (kind, fullname, span) so its several FULL prints (def view +
    elab view) merge into one object; a field present on ANY full print counts.
  * A count of OBJECTS and a count of DUMP LINE INSTANCES are different numbers
    and this pass needs both: 15 objects lost `vpiSigned` in SimpleUVM/default
    and 16 dump lines moved, because one object is printed fully twice.
    `--list` prints the per-object print count so the two reconcile.
"""
import collections
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402

VARKINDS = ('int_var', 'integer_var', 'byte_var', 'short_int_var',
            'long_int_var', 'time_var', 'bit_var', 'logic_var', 'ref_var',
            'enum_var', 'array_var', 'packed_array_var', 'real_var',
            'short_real_var', 'string_var', 'class_var', 'struct_var',
            'union_var', 'chandle_var')
ATOMTS = ('int_typespec', 'integer_typespec', 'byte_typespec',
          'short_int_typespec', 'long_int_typespec', 'logic_typespec',
          'bit_typespec', 'time_typespec')


def collect(path, kinds, typespecs=False):
    _r, nodes = parse(path)
    objs = {}
    for n in nodes:
        if typespecs:
            if not n.kind.endswith('_typespec') or n.kind == 'ref_typespec':
                continue
        elif n.kind not in kinds:
            continue
        if is_backref(n):
            continue
        k = (n.kind, n.name, n.span)
        e = objs.setdefault(k, {'signed': None, 'prints': 0, 'ts': [],
                                'par': set(), 'line': n.line})
        e['prints'] += 1
        if 'vpiSigned' in n.fields:
            e['signed'] = n.fields['vpiSigned']
        for f, c in n.children:
            if f == 'vpiParent':
                e['par'].add(c.kind)
            if f == 'vpiTypespec':
                if c.kind == 'ref_typespec':
                    for f2, c2 in c.children:
                        if f2 == 'vpiActual':
                            e['ts'].append((c2.kind, c2.name, c2.span))
                else:
                    e['ts'].append((c.kind, c.name, c.span))
    return objs


def tsclass(e, selfnamed=None):
    if selfnamed is not None:
        return 'NAMED' if selfnamed else 'ANON'
    if not e['ts']:
        return 'NOTS'
    kd, nm, _sp = e['ts'][0]
    return ('NAMED:' if nm else 'ANON:') + kd


def main():
    path = sys.argv[1]
    args = sys.argv[2:]
    if '--ts' in args:
        objs = collect(path, None, typespecs=True)
        tab = collections.Counter()
        for (kd, nm, _sp), e in objs.items():
            tab[(kd, 'NAMED' if nm else 'ANON', e['signed'] or '-')] += 1
        print('== TYPESPECS  %s' % path)
        for k in sorted(tab):
            if k[0] in ATOMTS:
                print('%-20s %-6s signed=%-4s %d' % (k[0], k[1], k[2], tab[k]))
        return
    if '--list' in args:
        kind = args[args.index('--list') + 1]
        objs = collect(path, (kind,))
        print('== NAMED-typespec objects of %s in %s' % (kind, path))
        rows = [(k, e) for k, e in objs.items()
                if e['ts'] and e['ts'][0][1]]
        for (kd, nm, sp), e in sorted(rows, key=lambda x: x[1]['line']):
            print('signed=%-3s L%-9d prints=%d %-68s @%-18s ts=%s(%s)@%s par=%s'
                  % (e['signed'] or '-', e['line'], e['prints'], nm, sp,
                     e['ts'][0][0], e['ts'][0][1], e['ts'][0][2],
                     ','.join(sorted(e['par']))))
        print('---- NAMED objects=%d  withSigned=%d  fullPrintsWithSigned>=%d'
              % (len(rows), sum(1 for _k, e in rows if e['signed']),
                 sum(1 for _k, e in rows if e['signed'])))
        return
    objs = collect(path, VARKINDS)
    tab = collections.Counter()
    for (kd, _nm, _sp), e in objs.items():
        tab[(kd, tsclass(e), e['signed'] or '-')] += 1
    print('== VARIABLES  %s' % path)
    for k in sorted(tab):
        print('%-16s %-26s signed=%-5s %d' % (k[0], k[1], k[2], tab[k]))


if __name__ == '__main__':
    main()
