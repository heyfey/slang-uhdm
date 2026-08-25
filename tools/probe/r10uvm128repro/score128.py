#!/usr/bin/env python3
"""r10uvm128 score128.py — MEASUREMENT ONLY (the official uhdm-cmp is the judge).

Two multiset censuses over a `uhdm-dump` text, both keyed on SPAN and NAME and
on NOTHING ELSE (no ids, no file — our objects carry an EMPTY VpiFile, RESUME
§9; no VpiFullName — no generated Compare reads it):

  OP   one row per `operation`      : opType | span | operand count
  HP   one row per `hier_path`      : name | span | the ordered element list
                                      (kind:name:span per `vpiActual`)

A `\\_kind:` line that follows a `|vpiParent:` field is a BACK-REFERENCE STUB the
dump prints for context, never an object; those are dropped, else every object
is counted twice and a NODEDUP census manufactures phantoms (RESUME §9).

usage: score128.py <dump> [OP|HP]      -> the rows, sorted
       score128.py -c <goldDump> <ourDump>   -> ONLY-GOLDEN / ONLY-OURS / SAME
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, ?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')


def parse(path):
    """Return (oprows, hprows) as Counters."""
    raw = open(path, errors='replace').read().split('\n')
    # A name that CONTAINS A NEWLINE (our pristine emits such objects for a
    # macro-spanning receiver whose text `rawText` read back as garbage) would
    # otherwise break the indentation tree and manufacture phantom rows.  Any
    # line that is not itself an object line or a field line is a CONTINUATION
    # of the previous one.
    lines = []
    for ln in raw:
        if OBJ.match(ln) or FLD.match(ln) or not lines:
            lines.append(ln)
        else:
            lines[-1] = lines[-1] + ' ' + ln.strip()
    ops = Counter()
    hps = Counter()
    # stack of (indent, kind, name, span, fieldname-that-introduced-it)
    stack = []
    cur_field = None
    # per-open-object accumulators
    acc = {}          # id(frame) -> dict
    frames = []
    for ln in lines:
        m = OBJ.match(ln)
        if m:
            ind, kind, name, rest = m.group(1), m.group(2), m.group(3) or '', m.group(4)
            span = ''
            sm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
            if sm:
                span = sm.group(1) + '-' + sm.group(2)
            stub = (cur_field == 'vpiParent')
            # pop frames at or deeper than this indent
            while frames and len(frames[-1]['ind']) >= len(ind):
                close(frames.pop(), ops, hps)
            if not stub:
                fr = {'ind': ind, 'kind': kind, 'name': name, 'span': span,
                      'optype': None, 'operands': 0, 'elems': [],
                      'field': cur_field}
                if frames:
                    frames[-1].setdefault('children', []).append(fr)
                frames.append(fr)
            cur_field = None
            continue
        f = FLD.match(ln)
        if f:
            ind, fname, val = f.group(1), f.group(2), f.group(3)
            while frames and len(frames[-1]['ind']) >= len(ind):
                close(frames.pop(), ops, hps)
            cur_field = fname
            if frames:
                fr = frames[-1]
                if fname == 'vpiOpType':
                    fr['optype'] = val.strip()
                elif fname == 'vpiOperand':
                    fr['operands'] += 1
                elif fname == 'vpiActual':
                    fr['elems'].append('PENDING')
            continue
        cur_field = None
    while frames:
        close(frames.pop(), ops, hps)
    return ops, hps


def close(fr, ops, hps):
    kids = fr.get('children', [])
    if fr['kind'] == 'operation':
        # The FIELD counter, not the child list: an object whose NAME contains a
        # `)` or a NEWLINE (our pristine emits exactly that for a macro-spanning
        # receiver read back as garbage) does not parse as an object line, and a
        # child-list count would report `nops=1` for an operation the dump shows
        # with two `vpiOperand` fields.  Counting the fields cannot be fooled.
        ops['OP\topType=%s\t%s\tnops=%d' % (fr['optype'], fr['span'],
                                             fr['operands'])] += 1
    elif fr['kind'] == 'hier_path':
        el = [k for k in kids if k['field'] == 'vpiActual']
        txt = ' '.join('%s:%s:%s' % (k['kind'], k['name'], k['span']) for k in el)
        hps['HP\t%s\t%s\t[%s]' % (fr['name'], fr['span'], txt)] += 1


def unparseable(path):
    """Dump lines that are NEITHER an object header NOR a field — i.e. the
    continuation lines of an object NAME that contains a NEWLINE.

    An object whose NAME contains a `)` or a NEWLINE — which is exactly what our
    PRISTINE emits for a macro-spanning receiver whose text `rawText` read back
    as a GARBAGE SPAN OF ANOTHER FILE — does not match the object regex, so it
    is invisible to the multiset census.  Counting it separately is what keeps
    "ONLY-OURS did not grow" an honest claim: those rows were never counted
    before the patch turned them into well-formed ones.
    """
    n = 0
    first = True
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        if OBJ.match(ln) or FLD.match(ln) or first:
            first = False
            continue
        n += 1
    return n


def rows(path, which):
    ops, hps = parse(path)
    c = ops if which == 'OP' else hps
    return c


if __name__ == '__main__':
    if sys.argv[1] == '-c':
        g, o = sys.argv[2], sys.argv[3]
        go, gh = parse(g)
        oo, oh = parse(o)
        gg = go + gh
        oz = oo + oh
        only_g = gg - oz
        only_o = oz - gg
        print('SAME %d  ONLY-GOLDEN %d  ONLY-OURS %d  UNPARSEABLE golden=%d ours=%d' %
              (sum((gg & oz).values()), sum(only_g.values()), sum(only_o.values()),
               unparseable(g), unparseable(o)))
        for k, v in sorted(only_g.items()):
            print('ONLY-GOLDEN\t%d\t%s' % (v, k))
        for k, v in sorted(only_o.items()):
            print('ONLY-OURS\t%d\t%s' % (v, k))
    else:
        which = sys.argv[2] if len(sys.argv) > 2 else 'HP'
        for k, v in sorted(rows(sys.argv[1], which).items()):
            print('%d\t%s' % (v, k))
