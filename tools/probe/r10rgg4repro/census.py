#!/usr/bin/env python3
"""r10rgg4/census.py — corpus-wide SOURCE prediction for § sizeDimOvrChain4.

The law only reaches an ELABORATED interface_array port whose dimension is the
SIZE form `[E]` with `E` a bare identifier; every other range site is untouched.
This walks both corpora's sources, finds every such declaration, and reports it
grouped by test, so the gate's mover set can be predicted BY NAME before any
sweep runs.

  usage: census.py [--verbose]

GUARD (measure the measurer): the scan also counts the declarations it saw but
DROPPED (a dimension that is not a bare identifier) and prints both totals; a
scan that matched nothing must never read as "no rows can move".
"""
import os, re, sys, collections

ROOTS = [
    (os.path.expanduser('~/git-repos/Surelog/tests'), 'surelog'),
    (os.path.expanduser('~/git-repos/Surelog/third_party/tests'), 'surelog3p'),
    (os.path.expanduser('~/git-repos/uhdm2rtlil/test'), 'u2r'),
]

# `ifc.modport name[DIM]` or `ifc name[DIM]` inside a port list: a TYPE token
# (optionally .modport), a declarator name, then ONE dimension.
PORT = re.compile(
    r'^\s*(?!input|output|inout|ref|wire|reg|logic|bit|byte|int|integer|'
    r'shortint|longint|real|time|string|parameter|localparam|typedef|genvar|'
    r'module|endmodule|interface|endinterface|package|assign|always|initial|'
    r'generate|function|task)'
    r'([A-Za-z_]\w*)(\.\w+)?\s+([A-Za-z_]\w*)\s*\[\s*([^\]]*?)\s*\]\s*[,)]',
    re.M)
BARE_ID = re.compile(r'^[A-Za-z_]\w*$')

def main():
    verbose = '--verbose' in sys.argv
    hit = collections.Counter()
    dropped = collections.Counter()
    rows = collections.defaultdict(list)
    files = 0
    for root, tag in ROOTS:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if not f.endswith(('.sv', '.v', '.svh', '.vh')):
                    continue
                path = os.path.join(dp, f)
                files += 1
                try:
                    txt = open(path, errors='replace').read()
                except OSError:
                    continue
                for m in PORT.finditer(txt):
                    ty, mp, nm, dim = m.groups()
                    # the test is the FIRST directory component under the root
                    rel = os.path.relpath(path, root)
                    test = rel.split(os.sep)[0]
                    key = f'{tag}:{test}'
                    if BARE_ID.match(dim):
                        hit[key] += 1
                        rows[key].append(f'{rel}:{ty}{mp or ""} {nm}[{dim}]')
                    else:
                        dropped[key] += 1
    print(f'# files scanned      : {files}')
    print(f'# BARE-ID dims (law) : {sum(hit.values())} in {len(hit)} tests')
    print(f'# other dims (dropped): {sum(dropped.values())} in {len(dropped)} tests')
    print('#')
    for k, n in sorted(hit.items(), key=lambda kv: (-kv[1], kv[0])):
        print(f'{n:4d}  {k}')
        if verbose:
            for r in sorted(set(rows[k])):
                print(f'        {r}')

if __name__ == '__main__':
    main()
