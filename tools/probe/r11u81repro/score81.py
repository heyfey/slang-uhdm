#!/usr/bin/env python3
"""r11u81 GRID SCORER — one cell per pattern OPERAND, scored on EVERY field
`expr::Compare` / `constant::Compare` / the typespec Compares read, as
`ts81probe` prints them (size, constType, value, decompile, and the typespec
chain INCLUDING `vpiSigned` and `Ranges`, which `uhdm-dump` does not print on
this path and `score78.py` therefore cannot see).

  TO      pristine != golden, law == golden          (a conversion)
  AWAY    pristine == golden, law != golden          (a regression)
  STILL   both differ from golden, law == pristine    (untouched)
  WRONG2  both differ from golden, law != pristine    (moved, still wrong)
  EQ      all three agree
A different operand COUNT or kind is reported as SHAPE and never joined.

Also scores the TYPESPEC AXIS alone (`--ts`), because a cell whose value is
already wrong can still convert its typespec.

usage: score81.py <griddir> <pris tag> <law tag> [<arm> ...]
       score81.py --ts <griddir> <pris tag> <law tag> [<arm> ...]
"""
import os
import re
import subprocess
import sys

PROBE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ts81probe')
ENV = dict(os.environ)
ENV['LD_LIBRARY_PATH'] = os.path.expanduser('~/.local/lib64') + ':' + \
    ENV.get('LD_LIBRARY_PATH', '')


def cells(path):
    """{(sect, name): [cellstring, ...]}"""
    out, key = {}, None
    try:
        t = subprocess.run([PROBE, path], capture_output=True, text=True,
                           env=ENV).stdout
    except OSError:
        return {}
    for ln in t.splitlines():
        m = re.match(r'^(\w+) (\S+) op(\d+) n=(\d+)', ln)
        if m:
            key = (m.group(1), m.group(2), m.group(3))
            out[key] = []
            continue
        m = re.match(r'^   \[\d+\] (.*)$', ln)
        if m and key is not None:
            out[key].append(m.group(1).strip())
    return out


def tspart(c):
    i = c.find(' ts=')
    return c[i + 4:] if i >= 0 else c


def main(gdir, ptag, ltag, arms, tsonly):
    tot = {'TO': 0, 'AWAY': 0, 'STILL': 0, 'WRONG2': 0, 'EQ': 0, 'SHAPE': 0}
    for a in arms:
        g = None
        d = os.path.join(gdir, 'g_' + a, 'slpp_all')
        if os.path.isdir(d):
            u = [f for f in sorted(os.listdir(d)) if f.endswith('.uhdm')]
            if u:
                g = os.path.join(d, u[0])
        p = os.path.join(gdir, 'o_%s_%s' % (a, ptag), 'ours.uhdm')
        l = os.path.join(gdir, 'o_%s_%s' % (a, ltag), 'ours.uhdm')
        if not (g and os.path.exists(p) and os.path.exists(l)):
            print('  %-16s MISSING DB' % a)
            continue
        G, P, L = cells(g), cells(p), cells(l)
        sub = {k: 0 for k in tot}
        lines = []
        for key in sorted(set(G) | set(P) | set(L)):
            gv, pv, lv = G.get(key), P.get(key), L.get(key)
            if gv is None or pv is None or lv is None or \
                    not (len(gv) == len(pv) == len(lv)):
                sub['SHAPE'] += 1
                lines.append('    SHAPE  %s g=%s p=%s l=%s'
                             % (key[1], len(gv) if gv is not None else '-',
                                len(pv) if pv is not None else '-',
                                len(lv) if lv is not None else '-'))
                continue
            for i, (gc, pc, lc) in enumerate(zip(gv, pv, lv)):
                if tsonly:
                    gc, pc, lc = tspart(gc), tspart(pc), tspart(lc)
                if gc == pc == lc:
                    sub['EQ'] += 1
                    continue
                if pc != gc and lc == gc:
                    k = 'TO'
                elif pc == gc and lc != gc:
                    k = 'AWAY'
                elif lc == pc:
                    k = 'STILL'
                else:
                    k = 'WRONG2'
                sub[k] += 1
                if k != 'STILL':
                    lines.append('    %-6s %s op%-2d\n       g=%s\n'
                                 '       p=%s\n       l=%s'
                                 % (k, key[1], i, gc, pc, lc))
        print('  %-16s TO=%d AWAY=%d STILL=%d WRONG2=%d EQ=%d SHAPE=%d'
              % (a, sub['TO'], sub['AWAY'], sub['STILL'], sub['WRONG2'],
                 sub['EQ'], sub['SHAPE']))
        for ln in lines:
            print(ln)
        for k in tot:
            tot[k] += sub[k]
    print('TOTAL TO=%d AWAY=%d STILL=%d WRONG2=%d EQ=%d SHAPE=%d'
          % (tot['TO'], tot['AWAY'], tot['STILL'], tot['WRONG2'], tot['EQ'],
             tot['SHAPE']))


if __name__ == '__main__':
    av = sys.argv[1:]
    ts = False
    if av and av[0] == '--ts':
        ts = True
        av = av[1:]
    gdir, ptag, ltag = av[0], av[1], av[2]
    arms = av[3:]
    if not arms:
        arms = sorted(set(
            f[2:-len('_' + ptag)] for f in os.listdir(gdir)
            if f.startswith('o_') and f.endswith('_' + ptag)))
    main(gdir, ptag, ltag, arms, ts)
