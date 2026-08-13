#!/usr/bin/env python3
"""r10uvm70 — THE POPULATION CENSUS, span-keyed, ONE SIDE PER RUN.

  usage: ct70pop.py <dump> [--list]

The head's shape is a VARIABLE whose OBJECT KIND and whose TYPESPEC KIND
DISAGREE about the base type:

    int_var  ->  ref_typespec -> logic_typespec        <- golden's shape for
                                                          `function unsigned f;`

so the census key is (variable kind, actual-typespec kind, vpiSigned), and the
row that matters is the MISMATCHED one.  Counting `int_var` alone would drown
the shape in the 900+ ordinary `int` variables of a UVM database; counting
`logic_typespec` alone would drown it in tens of thousands of logic nets.

CONVENTION: LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.  This script
reads ONE side; the CALLER states which.  Nothing here guesses.

TRAPS ENCODED (each already paid for by this campaign):
  * uhdm-dump's FIRST LINE is the database path -> callers pass `sed 1d` dumps.
  * AN OBJECT IS NOT A DUMP OCCURRENCE.  The same object is printed once with
    its children and again, CHILDLESSLY, wherever it is referenced.  A childless
    print carries NO fields, so counting it would report every object as
    unsigned and typespec-less.  Back-references are dropped and the object is
    keyed on (kind, fullname, span) so its several FULL prints (def view + elab
    view + the ref_typespec's own back-print) merge into ONE object.
  * A vpiTypespec is a `ref_typespec` WRAPPER; the kind that matters is its
    `vpiActual`.  Reading the wrapper's kind reports `ref_typespec` for every
    variable in the database.
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

# The base kind each variable class "should" agree with, so a MISMATCH row can
# be named mechanically instead of eyeballed.
NATURAL = {
    'int_var': 'int_typespec',
    'integer_var': 'integer_typespec',
    'byte_var': 'byte_typespec',
    'short_int_var': 'short_int_typespec',
    'long_int_var': 'long_int_typespec',
    'time_var': 'time_typespec',
    'bit_var': 'bit_typespec',
    'logic_var': 'logic_typespec',
    'enum_var': 'enum_typespec',
    'string_var': 'string_typespec',
    'real_var': 'real_typespec',
    'short_real_var': 'short_real_typespec',
    'class_var': 'class_typespec',
    'struct_var': 'struct_typespec',
    'union_var': 'union_typespec',
    'array_var': 'array_typespec',
    'packed_array_var': 'packed_array_typespec',
    'chandle_var': 'chandle_typespec',
}


def collect(path):
    _r, nodes = parse(path)
    objs = {}
    for n in nodes:
        if n.kind not in VARKINDS or is_backref(n):
            continue
        k = (n.kind, n.name, n.span)
        e = objs.setdefault(k, {'signed': '-', 'ts': '', 'par': set(),
                                'prints': 0, 'line': n.line})
        e['prints'] += 1
        if 'vpiSigned' in n.fields:
            e['signed'] = n.fields['vpiSigned']
        for f, c in n.children:
            if f == 'vpiTypespec':
                if c.kind == 'ref_typespec':
                    for f2, c2 in c.children:
                        if f2 == 'vpiActual' and not e['ts']:
                            e['ts'] = c2.kind
                elif not e['ts']:
                    e['ts'] = c.kind
            if f == 'vpiParent':
                e['par'].add(c.kind)
    return objs


def main():
    path = sys.argv[1]
    want_list = '--list' in sys.argv[2:]
    objs = collect(path)
    tab = collections.Counter()
    for (kind, _nm, _sp), e in objs.items():
        tab[(kind, e['ts'] or 'NOTS', e['signed'])] += 1
    print('DUMP=%s   objects=%d' % (path, len(objs)))
    print('%-18s %-24s %-8s %6s %s' % ('var kind', 'actual typespec', 'signed',
                                       'count', 'agreement'))
    for (kind, ts, sg), c in sorted(tab.items()):
        nat = NATURAL.get(kind)
        ag = 'MISMATCH' if (nat and ts != 'NOTS' and ts != nat) else ''
        print('%-18s %-24s %-8s %6d %s' % (kind, ts, sg, c, ag))
    print('---- MISMATCHED objects: %d'
          % sum(c for (k, ts, _s), c in tab.items()
                if NATURAL.get(k) and ts != 'NOTS' and ts != NATURAL[k]))
    if want_list:
        print('---- every MISMATCHED object (span-keyed)')
        for (kind, nm, sp), e in sorted(objs.items(),
                                        key=lambda kv: kv[0][2]):
            nat = NATURAL.get(kind)
            if not nat or not e['ts'] or e['ts'] == nat:
                continue
            print('  %-16s %-22s signed=%-3s %-40s parents=%s prints=%d'
                  % (kind, e['ts'], e['signed'], (nm or '')[:40], sp,
                     e['prints']))
            print('      %s' % ','.join(sorted(e['par'])))


if __name__ == '__main__':
    main()
