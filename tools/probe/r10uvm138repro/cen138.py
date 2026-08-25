#!/usr/bin/env python3
"""r10uvm138 — ENUM-CONSTANT REFERENCE census over a uhdm-dump TREE.

One CELL per `constant` or `ref_obj` REACHABLE IN THE DUMP TREE (RESUME §9:
a Serializer::AllObjects census can name objects that are not in the tree at
all).  The dump is the tree walk; this only parses it.

  CELL \t VIEW \t SITE \t SPAN \t KIND \t FIELDS

VIEW   the top-level design list the cell hangs under -- DEF for
       uhdmall{Packages,Modules,Classes,...}, TOP for uhdmtop{Packages,Modules}.
SITE   the ancestor path (kind(name) per level, plus the field label the leaf
       hangs on).  NO ids, NO file.
SPAN   line:col-endln:col.  Golden and ours span the SAME source text, so the
       span is the only key that can join a FOLDED constant (which carries no
       name at all) to the `ref_obj` it replaced.  It is a MEASUREMENT key,
       never a judge.
FIELDS constant: dc=<decompile>|sz=<size>|v=<VALUE>|ct=<constType>|ts=<typespec>
       ref_obj:  nm=<name>|act=<actual kind(name)>

LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
  usage: cen138.py <dump.txt>   (or - for stdin)
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_]+): (?:\(([^)]*)\))?\s*,?\s*(.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
TOPLIST = re.compile(r'^\|uhdm(\w+):')


def spanof(tail):
    m = SPAN.search(tail)
    return '%s:%s-%s:%s' % m.groups() if m else '-'


def main(path):
    fh = sys.stdin if path == '-' else open(path, 'rt', errors='replace')
    view = '?'
    # stack of [indent, kind, name, fieldlabel-of-child-being-read]
    stack = []
    pend = []            # (indent, kind, name, span, fields{}, fieldlabel)
    out = []

    def flush(node):
        ind, kind, name, span, fields, lbl = node
        if pend and lbl:                       # remember the child for the parent
            k = '_c_' + lbl
            if k not in pend[-1][4]:
                pend[-1][4][k] = '%s(%s)' % (kind, name) if name else kind
        if kind not in ('constant', 'ref_obj'):
            return
        if not fields:
            return          # a BACK-REFERENCE: the dump re-prints a visited
                            # object as a single line with no fields
        site = '/'.join(('%s(%s)' % (k, n)) if n else k for _, k, n, _, _, _ in pend)
        site = site + '#' + (lbl or '-')
        if kind == 'constant':
            f = 'dc=%s|sz=%s|v=%s|ct=%s|ts=%s' % (
                fields.get('vpiDecompile', '-'), fields.get('vpiSize', '-'),
                fields.get('_VAL', '-'), fields.get('vpiConstType', '-'),
                fields.get('vpiTypespec', '-'))
        else:
            f = 'nm=%s|act=%s' % (fields.get('vpiName', '-'), fields.get('_c_vpiActual', '-'))
        out.append('CELL\t%s\t%s\t%s\t%s\t%s' % (view, site, span, kind, f))

    lastlabel = None
    for line in fh:
        line = line.rstrip('\n')
        m = TOPLIST.match(line)
        if m:
            w = m.group(1)
            view = 'TOP' if w.startswith('top') else ('DEF' if w.startswith('all') else w)
            while pend:
                flush(pend.pop())
            lastlabel = None
            continue
        m = OBJ.match(line)
        if m:
            ind = len(m.group(1))
            while pend and pend[-1][0] >= ind:
                flush(pend.pop())
            pend.append((ind, m.group(2), m.group(3) or '', spanof(m.group(4)), {}, lastlabel))
            lastlabel = None
            continue
        m = FLD.match(line)
        if m:
            ind, key, val = len(m.group(1)), m.group(2), m.group(3)
            while pend and pend[-1][0] >= ind:
                flush(pend.pop())
            if val == '':
                lastlabel = key          # an object list follows
            elif pend:
                # `|INT:0` / `|STRING:x` is the uhdmValue tag, not a vpi field
                if key.isupper():
                    pend[-1][4]['_VAL'] = key + ':' + val
                else:
                    pend[-1][4][key] = val
            continue
    while pend:
        flush(pend.pop())
    sys.stdout.write('\n'.join(out) + ('\n' if out else ''))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else '-')
