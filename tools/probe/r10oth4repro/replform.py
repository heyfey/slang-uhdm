#!/usr/bin/env python3
"""replform.py -- read folded CONSTANTS out of a uhdm-dump with a real ancestor
chain, not a "nearest vpiDefName above" guess.

Why this exists: r10oth3's residue R1 shipped with NO WORKING DRIVER.  Its
`carm.sh` exits INSTRUMENT_BLIND_GOLDEN on a continuous-`assign` arm
(`asgform.py` hunts procedural `assignment` objects, of which such an arm has
ZERO), and `darm.sh`/`rangeform.py` read packed RANGES, not replication counts.
A driver that cannot find its probe reports perfection, so `--expect N` here is
a real positive control: it exits 3 rather than print a short, reassuring table.

TWO COUNTING TRAPS this parser exists to avoid, both of which bit r10oth3 and
the first cut of this file:

 1. **Back-references.** `|vpiParent:` / `|vpiActual:` / `|vpiTypespec:` edges
    print a FULL object header for an object defined elsewhere.  Counting those
    triples the constant count and attributes constants to the wrong module.
    This parser skips the whole subtree under a back-reference edge (see
    BACKREF).
 2. **"nearest vpiDefName above".** In a multi-module dump that lands a
    constant in whatever module happened to be printed last.  This parser
    carries a real indentation stack and reports the nearest enclosing
    `module_inst` DEF NAME plus the edge path.

Output, one line per constant DEFINITION:

    <view> <module> <edgepath> <span> ct<constType> sz<vpiSize> TAG:<value> nd=<n>

`nd` is the length of the digit string for BIN/OCT/HEX/DEC tags -- the field
that gates R1, because a constant's value string IS a `Compare` field.
`view` is DEF for the `uhdmallModules` region, ELAB for `uhdmtopModules`.
"""
import re
import sys

BACKREF = ('vpiParent', 'vpiActual', 'vpiTypespec', 'vpiInstance',
           'vpiModule', 'vpiTask', 'vpiFunction')
HDR = re.compile(r'^(\s*)\\_([A-Za-z_]+):\s*(.*)$')
EDGE = re.compile(r'^(\s*)\|([A-Za-z_]+):\s*(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
VALTAG = re.compile(r'^(BIN|OCT|DEC|HEX|INT|UINT|REAL|SCALAR|STRING):(.*)$')
DEFNAME = re.compile(r'^(\S+)\s')


def main():
    expect = 0
    args = list(sys.argv[1:])
    if '--expect' in args:
        i = args.index('--expect')
        expect = int(args[i + 1])
        del args[i:i + 2]
    only = None
    if '--kind' in args:
        i = args.index('--kind')
        only = args[i + 1]
        del args[i:i + 2]
    if len(args) != 1:
        sys.exit('usage: replform.py [--expect N] [--kind K] <dump>')
    lines = open(args[0], errors='replace').read().splitlines()

    view = 'PRE'
    # stack of dicts: {indent, kind, name, edge}
    stack = []
    skip_indent = None          # inside a back-reference subtree
    pending = [None]            # a BACKREF edge seen, payload header expected
    cur = None                  # constant being accumulated
    out = []

    def flush():
        nonlocal cur
        if cur is None:
            return
        vt, val = cur['tag'], cur['val']
        nd = len(val) if vt in ('BIN', 'OCT', 'DEC', 'HEX') else '-'
        if only is None or only == cur['kind']:
            # dc= is the vpiDecompile field.  It is a Compare field (YosysOldOr's
            # head printed `decompile:` as the differing tag), and golden ADDS
            # one to a truncated concat that had none -- so it must be in the
            # table, not left to a raw grep.
            out.append('%-4s %-14s %-34s %-16s ct%-3s sz%-4s %s:%s nd=%s dc=%s'
                       % (view, cur['mod'], cur['path'], cur['span'],
                          cur['ct'], cur['sz'], vt, val, nd,
                          cur.get('dec', '<NONE>')))
        cur = None

    for ln in lines:
        if 'uhdmallModules' in ln:
            flush()
            view = 'DEF'
        elif 'uhdmtopModules' in ln:
            flush()
            view = 'ELAB'

        m = HDR.match(ln)
        if m:
            ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
            # A BACK-REFERENCE payload header sits at the SAME indent as its
            # edge label, so `ind > skip_indent` alone would let it through and
            # then clear the skip.  pending_backref arms on the edge and this
            # is where it fires.
            if pending[0] is not None and ind == pending[0]:
                skip_indent = pending[0]
                pending[0] = None
                continue
            pending[0] = None
            if skip_indent is not None:
                if ind > skip_indent:
                    continue
                skip_indent = None
            flush()
            while stack and stack[-1]['indent'] >= ind:
                stack.pop()
            edge = stack[-1]['edge'] if stack else ''
            nm = ''
            dm = DEFNAME.match(rest)
            if dm and not dm.group(1).startswith(('line:', ',')):
                nm = dm.group(1).strip('()')
            stack.append({'indent': ind, 'kind': kind, 'name': nm, 'edge': ''})
            if kind == 'constant':
                mod = ''
                for fr in reversed(stack):
                    if fr['kind'] in ('module_inst', 'package', 'interface_inst'):
                        mod = fr['name'].split('@')[-1]
                        break
                path = '/'.join(f['kind'] for f in stack[-4:-1]) or 'root'
                sp = SPAN.search(rest)
                span = '%s:%s-%s:%s' % sp.groups() if sp else '-'
                cur = {'mod': mod or '?', 'path': path + ':' + edge,
                       'span': span, 'ct': '?', 'sz': '?', 'tag': '?',
                       'val': '?', 'kind': edge}
            continue

        e = EDGE.match(ln)
        if e:
            ind, name, rest = len(e.group(1)), e.group(2), e.group(3)
            if skip_indent is not None:
                if ind > skip_indent:
                    continue
                skip_indent = None
            while stack and stack[-1]['indent'] >= ind:
                stack.pop()
            if stack:
                stack[-1]['edge'] = name
            if name in BACKREF and not rest:
                pending[0] = ind
                continue
            pending[0] = None
            if cur is not None and stack and stack[-1]['kind'] == 'constant':
                if name == 'vpiSize':
                    cur['sz'] = rest
                elif name == 'vpiConstType':
                    cur['ct'] = rest
                elif name == 'vpiDecompile':
                    cur['dec'] = rest
            if cur is not None:
                v = VALTAG.match(name + ':' + rest)
                if v and cur['tag'] == '?':
                    cur['tag'], cur['val'] = v.group(1), v.group(2)
            continue
    flush()

    for o in out:
        print(o)
    if len(out) < expect:
        sys.stderr.write('replform: PROBE NOT FOUND -- %d constants, expected '
                         '>=%d\n' % (len(out), expect))
        sys.exit(3)


if __name__ == '__main__':
    main()
