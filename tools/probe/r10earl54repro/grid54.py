#!/usr/bin/env python3
"""r10earl54 GRID READER — print, per named ELABORATED instance, the vpiHighConn
subtree of one port, side by side for golden and ours.

WHY THIS AND NOT `diff`
-----------------------
The a1 grid puts ten replication CONTEXTS in one file; a whole-dump diff mixes
them with unrelated residues (net order, typespec ids) and cannot answer "did
THIS cell fold".  This walks the dump's indentation tree, finds the ELABORATED
`module_inst: ... (work@<top>.<inst>)` block (NOT the `ref_module` block of the
definition listing — that is a different Surelog code path that folds nothing,
and reading it produced this pass's one wrong measurement), descends to
`vpiPort:` / the named port / `vpiHighConn:`, and prints the subtree.

  usage: grid54.py <workdir> <port> <inst> [<inst> ...]
         grid54.py <workdir> --list          # every elaborated instance name
"""
import re
import sys


def indent(line):
    return len(line) - len(line.lstrip(' '))


def load(path):
    with open(path, 'rt', errors='replace') as f:
        return [l.rstrip('\n') for l in f]


def find_elab_inst(lines, inst):
    """Line index of the ELABORATED module_inst block header for `inst`.

    The elaborated block's parenthesised name is the FULL name
    (`work@top.u_ter`); the definition listing's is the SHORT one (`u_ter`) on a
    `ref_module` line.  Requiring the dot rejects the definition listing.
    """
    pat = re.compile(r'\\_module_inst: \S+ \(([^)]*\.' + re.escape(inst) + r')\)')
    for i, l in enumerate(lines):
        if pat.search(l):
            return i
    return -1


def block(lines, start):
    """[start, end) of the subtree headed at `start` (strictly deeper lines)."""
    base = indent(lines[start])
    j = start + 1
    while j < len(lines) and (not lines[j].strip() or indent(lines[j]) > base):
        j += 1
    return start, j


def port_highconn(lines, lo, hi, port):
    """Subtree of `vpiHighConn:` under the `vpiPort:` whose vpiName is `port`."""
    i = lo
    while i < hi:
        if lines[i].strip() == '|vpiPort:':
            # the port object is the next line; its block is the port
            ps, pe = block(lines, i + 1)
            nm = None
            for k in range(ps, pe):
                m = re.match(r'\s*\|vpiName:(.*)$', lines[k])
                if m and nm is None:
                    nm = m.group(1)
            if nm == port:
                for k in range(ps, pe):
                    if lines[k].strip() == '|vpiHighConn:':
                        return block(lines, k + 1)
                return None
            i = pe
            continue
        i += 1
    return None


def norm(lines, lo, hi):
    """Strip the leading indentation common to the subtree, drop file paths."""
    base = indent(lines[lo])
    out = []
    for k in range(lo, hi):
        s = lines[k]
        if not s.strip():
            continue
        s = s[base:] if len(s) > base else s.lstrip()
        s = re.sub(r'file:[^,]*,', 'file:*,', s)
        out.append(s)
    return out


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    wd = sys.argv[1]
    g = load(wd + '/g.dump')
    o = load(wd + '/o.dump')
    if sys.argv[2] == '--list':
        seen = []
        for l in g:
            m = re.search(r'\\_module_inst: \S+ \(([^)]*\.[^).]*)\)', l)
            if m and m.group(1) not in seen:
                seen.append(m.group(1))
        print('\n'.join(seen))
        return 0
    port = sys.argv[2]
    for inst in sys.argv[3:]:
        print('=' * 72)
        print('CELL %s  port=%s' % (inst, port))
        for tag, lines in (('GOLDEN', g), ('OURS  ', o)):
            i = find_elab_inst(lines, inst)
            if i < 0:
                print('  %s: NO-ELAB-INSTANCE' % tag)
                continue
            lo, hi = block(lines, i)
            hc = port_highconn(lines, lo, hi, port)
            if hc is None:
                print('  %s: NO-HIGHCONN' % tag)
                continue
            print('  --- %s' % tag)
            for s in norm(lines, hc[0], hc[1]):
                print('    ' + s)
    return 0


if __name__ == '__main__':
    sys.exit(main())
