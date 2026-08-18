#!/usr/bin/env python3
"""vrgg15 verifier census: extract every param_assign (Lhs param fullname ->
Rhs constant judge fields + span presence) from a uhdm-dump text tree."""
import re, sys, subprocess, os

DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')

def dump(path):
    return subprocess.run([DUMP, path], capture_output=True, text=True).stdout

NODE = re.compile(r'^(\s*)\\_([a-z_0-9]+): ?(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')

def parse(text):
    """Return list of (path_of_kinds, node_dict). Node dict has 'kind','hdr',fields."""
    root = {'kind': 'design', 'hdr': '', 'fields': {}, 'kids': [], 'ind': -1, 'slot': None}
    stack = [root]
    cur_slot = None
    for line in text.splitlines():
        m = NODE.match(line)
        if m:
            ind = len(m.group(1))
            while len(stack) > 1 and stack[-1]['ind'] >= ind:
                stack.pop()
            n = {'kind': m.group(2), 'hdr': m.group(3), 'fields': {}, 'kids': [],
                 'ind': ind, 'slot': cur_slot}
            stack[-1]['kids'].append(n)
            stack.append(n)
            continue
        m = FIELD.match(line)
        if m:
            ind = len(m.group(1))
            while len(stack) > 1 and stack[-1]['ind'] >= ind:
                stack.pop()
            k, v = m.group(2), m.group(3)
            cur_slot = k
            if v != '':
                stack[-1]['fields'].setdefault(k, []).append(v)
    return root

SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

def constrec(c):
    f = c['fields']
    sp = SPAN.search(c['hdr'])
    ts = None
    for k in c['kids']:
        if k['slot'] == 'vpiTypespec':
            for kk in k['kids']:
                if kk['slot'] == 'vpiActual':
                    ts = kk['kind']
    return dict(
        kind=c['kind'],
        dec=(f.get('vpiDecompile') or [''])[0],
        size=(f.get('vpiSize') or ['<none>'])[0],
        ct=(f.get('vpiConstType') or ['<none>'])[0],
        val=next((k for k in ('UINT','INT','BIN','HEX','OCT','DEC','REAL','STRING')
                  if k in f), '?') ,
        valv=next((f[k][0] for k in ('UINT','INT','BIN','HEX','OCT','DEC','REAL','STRING')
                   if k in f), '?'),
        ts=ts or '<none>',
        span=('L%s:%s-%s:%s' % sp.groups()) if sp else '<nospan>',
    )

def walk(n, out, ownerstack):
    kind = n['kind']
    name = ''
    mm = re.match(r'^([^,]*?)(?:,|$)', n['hdr'])
    hdrname = n['hdr'].split(',')[0].strip()
    if kind == 'param_assign':
        lhs = rhs = None
        for k in n['kids']:
            if k['slot'] == 'vpiLhs': lhs = k
            if k['slot'] == 'vpiRhs': rhs = k
        key = ''
        if lhs is not None:
            key = (lhs['fields'].get('vpiFullName') or [lhs['hdr']])[0]
        rec = constrec(rhs) if rhs is not None else {'kind': '<norhs>'}
        out.append((key, rec))
    for k in n['kids']:
        walk(k, out, ownerstack)

def collect(path):
    root = parse(dump(path))
    out = []
    walk(root, out, [])
    # multiset: key -> sorted list of payloads
    d = {}
    for k, r in out:
        pay = '%s dec=%s sz=%s ct=%s %s=%s ts=%s' % (r.get('kind'), r.get('dec'),
              r.get('size'), r.get('ct'), r.get('val'), r.get('valv'), r.get('ts'))
        d.setdefault(k, []).append((pay, r.get('span')))
    for k in d: d[k].sort()
    return d

if __name__ == '__main__':
    g = collect(sys.argv[1])
    if len(sys.argv) == 2:
        for k in sorted(g):
            for p, s in g[k]: print('%-52s %s | span=%s' % (k, p, s))
        sys.exit(0)
    a = collect(sys.argv[2])
    b = collect(sys.argv[3]) if len(sys.argv) > 3 else None
    keys = sorted(set(g) | set(a) | (set(b) if b else set()))
    nf = nb = ns = 0
    for k in keys:
        G = g.get(k, []); A = a.get(k, []); B = b.get(k, []) if b else None
        gp = [x[0] for x in G]; ap = [x[0] for x in A]
        gs = [x[1] for x in G]; asp = [x[1] for x in A]
        if b is None:
            tag = 'SAME' if gp == ap else 'DIFF'
            if gp != ap: nf += 1
            print('%-6s %-52s\n   G %s\n   O %s' % (tag, k, G, A))
        else:
            bp = [x[0] for x in B]; bs = [x[1] for x in B]
            shape = ('EQ' if bp == gp else 'NE')  # base
            shape2 = ('EQ' if ap == gp else 'NE')  # patched
            spb = ('EQ' if bs == gs else 'NE')
            spa = ('EQ' if asp == gs else 'NE')
            verdict = {('NE','EQ'):'FIXED', ('EQ','NE'):'BROKEN',
                       ('EQ','EQ'):'STILL-OK', ('NE','NE'):'STILL-WRONG'}[(shape,shape2)]
            sverdict = {('NE','EQ'):'SPAN-FIXED', ('EQ','NE'):'SPAN-BROKEN',
                        ('EQ','EQ'):'SPAN-OK', ('NE','NE'):'SPAN-WRONG'}[(spb,spa)]
            if verdict=='FIXED': nf+=1
            if verdict=='BROKEN': nb+=1
            print('%-12s %-12s %-46s' % (verdict, sverdict, k))
            if verdict != 'STILL-OK' or sverdict != 'SPAN-OK':
                print('   GOLD %s' % G)
                print('   BASE %s' % B)
                print('   PAT  %s' % A)
    print('== keys=%d FIXED=%d BROKEN=%d' % (len(keys), nf, nb))
