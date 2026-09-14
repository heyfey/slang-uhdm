#!/usr/bin/env python3
"""r11u24 — the LEFTOVER census: every `typespec_member` that carries a value
annotation, keyed by (section, struct typespec name, member name).

`ExprEval::setValueInInstance` stamps a function-built struct's member values
onto the SHARED struct typespec as `typespec_member::Actual_value`; uhdm-dump
prints that as a `|vpiExpr:` child of the member.  A struct typespec appears
once per view, so the key carries the section.

    memcen24.py <dump> [<dump2> ...]
"""
import re, sys

SECT = re.compile(r'^\|uhdm(\w+):')


def ind(s):
    return len(s) - len(s.lstrip(' '))


def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    sect = '?'
    stack = []          # (indent, struct typespec name)
    out = {}
    i, n = 0, len(lines)
    while i < n:
        l = lines[i]
        m = SECT.match(l)
        if m:
            sect = m.group(1)
            stack = []
            i += 1
            continue
        ms = re.match(r'^(\s*)\\_struct_typespec: \(([^)]*)\)', l)
        if ms:
            while stack and stack[-1][0] >= ind(l):
                stack.pop()
            stack.append((ind(l), ms.group(2)))
            i += 1
            continue
        mm = re.match(r'^(\s*)\\_typespec_member: \(([^)]*)\)', l)
        if mm:
            base = ind(l)
            while stack and stack[-1][0] >= base:
                stack.pop()
            owner = stack[-1][1] if stack else '?'
            mem = mm.group(2)
            # the member block
            j = i + 1
            blk = []
            while j < n and (lines[j].strip() == '' or ind(lines[j]) > base):
                blk.append(lines[j])
                j += 1
            val = None
            k = 0
            while k < len(blk):
                if blk[k].strip() == '|vpiExpr:' and ind(blk[k]) == base + 2:
                    # the child object, expanded or collapsed
                    if k + 1 < len(blk):
                        hm = re.match(r'^(\s*)\\_(\w+):\s*(.*)$', blk[k + 1])
                        if hm:
                            cb = ind(blk[k + 1])
                            cells = {'kind': hm.group(2), 'dec': '', 'size': '',
                                     'ct': '', 'val': ''}
                            lm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)',
                                           hm.group(3))
                            cells['loc'] = (lm.group(1) + '-' + lm.group(2)
                                            ) if lm else 'NOLOC'
                            q = k + 2
                            while q < len(blk) and ind(blk[q]) > cb:
                                t = blk[q].strip()
                                if t.startswith('|vpiDecompile:'):
                                    cells['dec'] = t[len('|vpiDecompile:'):]
                                elif t.startswith('|vpiSize:'):
                                    cells['size'] = t[len('|vpiSize:'):]
                                elif t.startswith('|vpiConstType:'):
                                    cells['ct'] = t[len('|vpiConstType:'):]
                                elif re.match(r'^\|(UINT|INT|BIN|HEX|OCT|DEC|REAL|STRING):', t):
                                    cells['val'] = t[1:]
                                q += 1
                            if cells['dec'] or cells['val'] or cells['size']:
                                val = cells
                    # only the FIRST vpiExpr carries the expansion
                if val:
                    break
                k += 1
            if val:
                out[(sect, owner, mem)] = val
            i = j
            continue
        i += 1
    return out


def show(path):
    d = parse(path)
    print('==', path)
    for k in sorted(d):
        c = d[k]
        print('  %-14s %-22s %-8s kind=%s dec=%s size=%s ct=%s val=%s [loc=%s]'
              % (k[0], k[1], k[2], c['kind'], c['dec'], c['size'], c['ct'],
                 c['val'], c['loc']))


if __name__ == '__main__':
    for p in sys.argv[1:]:
        show(p)
