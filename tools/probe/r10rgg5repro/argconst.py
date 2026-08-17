#!/usr/bin/env python3
"""r10rgg5/gncensus.py -- census EVERY get_next_n call in a uhdm-dump.

For each `func_call: (get_next_n)` object occurrence (not the vpiParent
backrefs) print: call-site line, the ARGUMENT's kind, its vpiSize, its
vpiConstType and its vpiDecompile (elided), plus the instance path recovered
from the first vpiFullName inside the call's subtree.

GUARD: a call whose argument cannot be identified prints ARG=?? and is COUNTED,
so an unparsed shape can never read as agreement.  A file yielding ZERO calls
exits 3.
"""
import re, sys, collections

path = sys.argv[1]
tag  = sys.argv[2] if len(sys.argv) > 2 else path
OBJ  = re.compile(r'^(\s*)\\_(\w+): (.*)$')
FLD  = re.compile(r'^(\s*)\|(\w+):(.*)$')

lines = open(path, errors='replace').read().split('\n')
n = len(lines)
hits = []
for i, L in enumerate(lines):
    m = OBJ.match(L)
    if not m or m.group(2) != 'func_call':
        continue
    if not m.group(3).startswith('(get_next_n)'):
        continue
    # a vpiParent backref is preceded by a `|vpiParent:` field line
    if i and lines[i-1].strip() == '|vpiParent:':
        continue
    ind = len(m.group(1))
    site = re.search(r'line:(\d+:\d+)', m.group(3))
    site = site.group(1) if site else '?'
    # scan the subtree (indent > ind) for the argument
    arg = None; argkind = None; sz = ct = dec = None; full = None
    j = i + 1
    inarg = False; argind = None
    while j < n:
        mo = OBJ.match(lines[j]); mf = FLD.match(lines[j])
        cur = mo or mf
        if cur is None:
            j += 1; continue
        cind = len(cur.group(1))
        if cind <= ind:
            break
        if mf and mf.group(2) == 'vpiArgument' and cind == ind + 2:
            inarg = True; argind = cind; j += 1; continue
        if inarg and mo and argkind is None and cind == argind:
            argkind = mo.group(2)
            argsite = re.search(r'line:(\d+:\d+)', mo.group(3))
            argsite = argsite.group(1) if argsite else '?'
            j += 1; continue
        if argkind and mf and cind == argind + 2:
            k, v = mf.group(2), mf.group(3)
            if k == 'vpiSize': sz = v
            elif k == 'vpiConstType': ct = v
            elif k == 'vpiDecompile': dec = v
            elif k in ('vpiName', 'vpiFullName') and full is None and argkind != 'constant':
                full = v
        if mf and mf.group(2) == 'vpiFullName' and full is None:
            full = mf.group(3)
        j += 1
    if argkind is None:
        argkind = '??'
    hits.append((site, argkind, sz, ct, dec, full))

if not hits:
    sys.stderr.write('FATAL: no get_next_n call found in %s\n' % path)
    sys.exit(3)

def short(d):
    if d is None: return '-'
    if len(d) <= 24: return d
    s = d.lstrip('0')
    z = len(d) - len(s)
    return '<%dz>%s' % (z, s if s else '0')

grp = collections.Counter()
for site, argkind, sz, ct, dec, full in hits:
    grp[(site, argkind, sz, ct, short(dec))] += 1
print('== %s : %d get_next_n calls' % (tag, len(hits)))
for k, c in sorted(grp.items(), key=lambda kv: (-kv[1], kv[0])):
    print('  %4d  site=%-10s arg=%-10s size=%-5s ct=%-3s dec=%s' % (c, k[0], k[1], k[2], k[3], k[4]))
print('  UNPARSED=%d' % sum(1 for h in hits if h[1] == '??'))
# per-instance detail
print('-- per-instance (site, path, dec)')
for site, argkind, sz, ct, dec, full in hits:
    print('   %-10s %-10s %-6s %-24s %s' % (site, argkind, sz or '-', short(dec), full or '-'))
