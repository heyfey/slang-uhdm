#!/usr/bin/env python3
"""cells114.py gold.txt pris.txt law.txt — per-CELL scorer over uhdm-dump text.
A cell = (section, kind, name, five-field span, compare-visible direct props:
value/size/decompile/const type/op type/name + typespec actual kind); parent and
fullname are left OUT of the key (no Compare reads them).  Deduped per dump.
For every cell law gained or lost against pris: TO (moves toward golden),
AWAY (moves off golden), WRONG (gained, not in golden; lost, not in golden).
Calibrate by passing the same dump three times (all counts 0)."""
import sys, re
KEEP = re.compile(r'^\|(UINT|INT|BIN|HEX|DEC|OCT|STRING|REAL|vpiSize|vpiName|vpiDecompile|vpiConstType|vpiOpType)')
SECS = (('|uhdmallModules', 'DEF'), ('|uhdmtopModules', 'TOP'), ('|uhdmallPackages', 'PKGDEF'),
        ('|uhdmtopPackages', 'PKGTOP'), ('|uhdmallClasses', 'CLS'), ('|uhdmallInterfaces', 'IFDEF'),
        ('\\_weaklyReferenced', 'WEAK'))
def cells(path):
    L = open(path, errors='replace').read().split('\n')
    sec = 'HDR'; out = set()
    for i, l in enumerate(L):
        for k, v in SECS:
            if l.startswith(k): sec = v
        m = re.match(r'^(\s*)\\_(\w+): (.*?)(?:, id:\d+)?(?:, file:[^,]*)?, line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if not m:
            m2 = re.match(r'^(\s*)\\_(\w+): (.*?)(?:, id:\d+)?$', l)
            if not m2: continue
            ind = len(m2.group(1)); kind = m2.group(2); name = m2.group(3); span = '-'
        else:
            ind = len(m.group(1)); kind = m.group(2); name = m.group(3); span = '%s:%s-%s:%s' % m.group(4, 5, 6, 7)
        props = []; j = i + 1
        while j < len(L):
            s = L[j]; si = len(s) - len(s.lstrip())
            if si <= ind: break
            st = s.strip()
            if si == ind + 2 and KEEP.match(st): props.append(st)
            if si == ind + 2 and st in ('|vpiActual:', '|vpiTypespec:'):
                nx = L[j + 1].strip() if j + 1 < len(L) else ''
                props.append(st[1:-1] + '=' + nx.split(':')[0])
            j += 1
        if j == i + 1: continue
        if sec == 'WEAK': continue
        name = re.sub(r'\(.*\)', '()', name) if kind in ('ref_typespec',) else name
        out.add((sec, kind, name, span, ' '.join(props)))
    return out
g, p, w = (cells(x) for x in sys.argv[1:4])
lost = p - w; gained = w - p
to = [c for c in gained if c in g] + [c for c in lost if c not in g]
away = [c for c in lost if c in g]
wrong = [c for c in gained if c not in g]
print('CELLS gained=%d lost=%d TO=%d AWAY=%d WRONG-GAINED=%d' % (len(gained), len(lost), len(to), len(away), len(wrong)))
for c in sorted(away): print('  AWAY  ', ' | '.join(c)[:220])
for c in sorted(wrong): print('  WRONG ', ' | '.join(c)[:220])
if len(sys.argv) > 4:
    for c in sorted(to): print('  TO    ', ' | '.join(c)[:220])
