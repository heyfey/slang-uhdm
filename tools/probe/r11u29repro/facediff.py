#!/usr/bin/env python3
"""r11u29repro/facediff.py — the FACE of an official uhdm-cmp head.

uhdm-cmp prints the head object's decompile on both sides.  The FACE is the
BLIND DIFF of those two renderings:

  * ids are blinded            (`id:N`     -> `id:#`)  — per-design, never a fact
  * source locations blinded   (`line:`, `endln:`, `col:`, `file:`)
                               — NO generated Compare reads VpiFile/line/col
                                 (RESUME.md 9), so a location-only difference is
                                 NOISE, not the head's field
  * vpiFullName blinded        — Compare never reads VpiFullName (RESUME.md 9);
                                 the dump SYNTHESIZES it from the parent chain

What survives is the field the judge actually disagreed on, or `<null>` when
the singular overload fired with our side missing.

usage: facediff.py <file.cmp> [...]   -> one FACE block per file on stdout
       facediff.py --key <file.cmp>   -> one line per file: the face KEY
"""
import re
import sys
import os

BLIND = [
    (re.compile(r'id:\d+'), 'id:#'),
    (re.compile(r'line:\d+:\d+'), 'line:#'),
    (re.compile(r'endln:\d+:\d+'), 'endln:#'),
    (re.compile(r'col:\d+'), 'col:#'),
    (re.compile(r'file:[^,]*'), 'file:#'),
    (re.compile(r'\|vpiFullName:.*'), '|vpiFullName:#'),
]


def blind(line):
    for rx, rep in BLIND:
        line = rx.sub(rep, line)
    return line.rstrip()


def split_head(path):
    txt = [l.rstrip('\n') for l in open(path, errors='replace')]
    if not txt:
        return None, None
    # `LHS:` alone opens golden's decompile.  `LHS: <null>` is the MIRROR of the
    # singular overload (RESUME.md 9): golden has NOTHING where we emit an
    # object — an OVER-emission, the opposite reading from `RHS: <null>`.
    i = None
    for j, ln in enumerate(txt):
        if ln == 'LHS:' or ln.startswith('LHS: '):
            i = j
            break
    if i is None:
        return None, None
    if txt[i].strip() == 'LHS: <null>':
        tail = txt[i + 1:]
        if tail and tail[0].startswith('RHS:'):
            tail = tail[1:]
        return ['<null>'], tail
    rhs_i = None
    for j in range(i + 1, len(txt)):
        if txt[j].startswith('RHS:'):
            rhs_i = j
            break
    lhs = txt[i + 1:rhs_i]
    if rhs_i is None:
        return lhs, None
    if txt[rhs_i].strip() == 'RHS: <null>':
        return lhs, ['<null>']
    rhs = txt[rhs_i + 1:]
    return lhs, rhs


def one_decompile(block):
    """the FIRST decompile only — cmp prints it twice for one head."""
    out = []
    seen = 0
    for ln in block:
        if ln.startswith('decompile:'):
            seen += 1
            if seen > 1:
                break
            continue
        out.append(blind(ln))
    while out and not out[-1]:
        out.pop()
    return out


def face(path):
    lhs, rhs = split_head(path)
    if lhs is None:
        return 'EQUAL', [], []
    if lhs == ['<null>']:
        R = one_decompile(rhs) if rhs else []
        kind = R[0].split(':')[0] if R else '?'
        return 'GOLDEN-NULL:' + kind, ['<null>'], R
    L = one_decompile(lhs)
    if rhs == ['<null>']:
        kind = L[0].split(':')[0] if L else '?'
        return 'OURS-NULL:' + kind, L, ['<null>']
    R = one_decompile(rhs)
    ls, rs = set(L), set(R)
    only_g = [x for x in L if x not in rs]
    only_o = [x for x in R if x not in ls]
    if not only_g and not only_o:
        # same rendered text on both sides: the disagreement is in a field the
        # decompile does not print (or an order/size difference below it)
        kind = L[0].split(':')[0] if L else '?'
        return 'SAME-RENDER:' + kind, L, R
    def fields(lines):
        f = []
        for x in lines:
            m = re.match(r'^\s*\|(\w+):', x)
            if m:
                f.append(m.group(1))
            else:
                m2 = re.match(r'^\s*\\?_?([a-z_0-9]+):', x)
                if m2:
                    f.append('<' + m2.group(1) + '>')
        return f
    kind = L[0].split(':')[0] if L else '?'
    key = '%s G[%s] O[%s]' % (kind, '+'.join(fields(only_g)) or '-',
                              '+'.join(fields(only_o)) or '-')
    return key, only_g, only_o


def main():
    keyonly = '--key' in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    for p in sorted(args):
        k, g, o = face(p)
        stem = os.path.basename(p)[:-4]
        if keyonly:
            print('%-46s %s' % (stem, k))
        else:
            print('######## %s   FACE=%s' % (stem, k))
            for x in g:
                print('  GOLDEN-ONLY  ' + x.strip())
            for x in o:
                print('  OURS-ONLY    ' + x.strip())


if __name__ == '__main__':
    main()
