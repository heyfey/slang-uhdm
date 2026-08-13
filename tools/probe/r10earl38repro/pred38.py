#!/usr/bin/env python3
"""r10earl38 — the SOURCE-TEXT POPULATION instrument (weak by construction).

Counts, per corpus test, the `else if` GENERATE chains whose branches sit
inside another generate scope and hold at least one item that needs the AST
scope (a declaration, a localparam, an always/initial, or a nested generate).
That is the population § genChainBranchScopeThreads38 can reach.

STATED WEAKNESS — read this before quoting any number it prints.  The
discriminator of this law is WHICH EMITTER compiles the branch, and that is not
visible in source text:

  * a chain at MODULE LEVEL is ALREADY CORRECT (the `!astBlock` fallback
    searches the module body and finds the branches there), and it is written
    with exactly the same characters as a broken one inside a gen-for;
  * `if`/`else if` inside a PROCEDURAL block is not a generate chain at all and
    this instrument cannot always tell them apart from indentation;
  * a branch whose only items are cont-assigns or instances needs no scope and
    never moves.

So this instrument OVER-COUNTS.  The fence that binds is the OBJECT-level one
in `cenpred38.sh`, computed from the actual dumps, which on Earlgrey predicted
10 movers where this script's own reachable-branch count is far larger.  It is
kept because it is the only instrument that shows how big the WRITTEN
population is against how small the REACH is — which is itself the finding.

usage: pred38.py <dir> [<dir> ...]
"""
import os
import re
import sys

# `end else if (...) begin : label` / `else if (...) begin : label` — a chain
# branch that opens a NAMED block.  A generate chain nearly always names its
# branches (an unnamed one produces no named_begin to lose statements from).
CHAIN = re.compile(r'\belse\s+if\s*\(.*\)\s*begin\s*:\s*(\w+)')
GENFOR = re.compile(r'\bfor\s*\(\s*genvar\b')
NEEDS = re.compile(r'^\s*(logic|bit|reg|int|integer|byte|shortint|longint|'
                   r'localparam|parameter|always|always_comb|always_ff|'
                   r'always_latch|initial|if|for|case)\b')
SRC = ('.sv', '.v', '.svh', '.vh')


def scan(path):
    """-> (chain branches opened, of which inside a gen-for, of which the
    branch body holds a scope-needing item)."""
    try:
        lines = open(path, 'rt', errors='replace').read().splitlines()
    except OSError:
        return (0, 0, 0)
    tot = infor = needy = 0
    genfor_depth = []          # begin-depth at which each open gen-for started
    depth = 0
    for i, ln in enumerate(lines):
        code = ln.split('//')[0]
        if GENFOR.search(code):
            genfor_depth.append(depth)
        m = CHAIN.search(code)
        if m:
            tot += 1
            inside = bool(genfor_depth)
            if inside:
                infor += 1
                # Does the branch body hold an item that needs the AST scope?
                for j in range(i + 1, min(i + 40, len(lines))):
                    body = lines[j].split('//')[0]
                    if re.match(r'^\s*end\b', body):
                        break
                    if NEEDS.match(body):
                        needy += 1
                        break
        depth += len(re.findall(r'\bbegin\b', code))
        for _ in re.findall(r'\bend\b(?!\w)', code):
            depth -= 1
            while genfor_depth and genfor_depth[-1] >= depth:
                genfor_depth.pop()
    return (tot, infor, needy)


def main():
    roots = sys.argv[1:]
    if not roots:
        sys.exit(__doc__)
    tot = infor = needy = files = 0
    hits = []
    for root in roots:
        for dirpath, _, fns in os.walk(root):
            for fn in fns:
                if not fn.endswith(SRC):
                    continue
                p = os.path.join(dirpath, fn)
                t, f, n = scan(p)
                files += 1
                tot += t
                infor += f
                needy += n
                if n:
                    hits.append((n, p))
    hits.sort(reverse=True)
    print('files scanned              : %d' % files)
    print('`else if ... begin :` total: %d' % tot)
    print('  ...inside a gen-for      : %d' % infor)
    print('  ...with a scope-needing item in the branch: %d   <- the'
          ' OVER-COUNTED population' % needy)
    print('top files:')
    for n, p in hits[:15]:
        print('  %4d  %s' % (n, p))


if __name__ == '__main__':
    main()
