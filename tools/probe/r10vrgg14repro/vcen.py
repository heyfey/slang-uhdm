#!/usr/bin/env python3
"""r10vrgg14 — owner-keyed census of every bit_select / var_select / part_select
INDEX payload in a uhdm-dump text, with a Compare-VISIBLE payload only
(VpiDecompile / VpiSize / VpiValue / VpiConstType / kind), keyed by the owner's
vpiFullName + its own span.  Span is reported separately (Compare never reads
it) so a span move is scored but not confused with a Compare-visible one."""
import sys, re, collections

NODE = re.compile(r'^(\s*)\\_(\w+): ?(.*)$')
FIELD = re.compile(r'^(\s*)\|(\w+):\s*(.*)$')

def parse(path):
    """Return list of (indent, kind, header, fields{}, children[]) tree roots."""
    if path.endswith('.uhdm'):
        import subprocess, os
        txt = subprocess.run([os.path.expanduser('~/.local/bin/uhdm-dump'), path],
                             capture_output=True, text=True).stdout
        lines = txt.split('\n')
    else:
        lines = open(path, errors='replace').read().split('\n')
    root = {'kind':'ROOT','hdr':'','ind':-1,'f':{},'c':[],'pending':None}
    stack = [root]
    for ln in lines:
        if not ln.strip():
            continue
        m = NODE.match(ln)
        if m:
            ind = len(m.group(1)); kind = m.group(2); hdr = m.group(3)
            while stack and stack[-1]['ind'] >= ind:
                stack.pop()
            parent = stack[-1]
            node = {'kind':kind,'hdr':hdr,'ind':ind,'f':{},'c':[],
                    'slot':parent.get('pending'),'pending':None}
            parent['c'].append(node)
            parent['pending'] = None
            stack.append(node)
            continue
        m = FIELD.match(ln)
        if m:
            ind = len(m.group(1)); key = m.group(2); val = m.group(3)
            while stack and stack[-1]['ind'] >= ind:
                stack.pop()
            cur = stack[-1]
            if val == '':
                cur['pending'] = key
            else:
                cur['f'][key] = val
            continue
        # value lines like |UINT:0 / |INT:2 / |BIN:0
        m2 = re.match(r'^(\s*)\|([A-Z]+):(.*)$', ln)
        if m2:
            ind = len(m2.group(1))
            while stack and stack[-1]['ind'] >= ind:
                stack.pop()
            stack[-1]['f']['__VALUE'] = m2.group(2)+':'+m2.group(3)
    return root

SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
def span(node):
    m = SPAN.search(node['hdr'])
    return '%s:%s-%s:%s' % m.groups() if m else 'nospan'

def payload(n):
    if n['kind'] == 'constant':
        return 'constant|dec=%s|sz=%s|val=%s|ct=%s' % (
            n['f'].get('vpiDecompile','-'), n['f'].get('vpiSize','-'),
            n['f'].get('__VALUE','-'), n['f'].get('vpiConstType','-'))
    if n['kind'] == 'ref_obj':
        return 'ref_obj|%s' % n['f'].get('vpiName','-')
    if n['kind'] == 'operation':
        return 'operation|op=%s|nops=%d' % (n['f'].get('vpiOpType','-'),
                                            len([c for c in n['c'] if c['slot']=='vpiOperand']))
    return n['kind']

def walk(n, path, out):
    # owner key: nearest named ancestor chain is too noisy; use the node's own
    # fullname when it has one, else the parent's + slot.
    for c in n['c']:
        fn = c['f'].get('vpiFullName') or c['f'].get('vpiName') or ''
        p2 = path + '/' + c['kind'] + (':'+fn if fn else '') + '@' + span(c)
        if c['kind'] in ('bit_select','var_select','part_select',
                         'indexed_part_select','hier_path','constant',
                         'ref_obj','operation'):
            for gc in c['c']:
                if gc['slot'] in ('vpiIndex','vpiBaseExpr','vpiWidthExpr',
                                  'vpiLeftRange','vpiRightRange'):
                    out.append((p2 + '#' + gc['slot'], payload(gc), span(gc)))
        walk(c, p2, out)

def collect(path):
    root = parse(path)
    out = []
    walk(root, '', out)
    return out

if __name__ == '__main__':
    a = collect(sys.argv[1])
    for k,p,s in sorted(a):
        print('%s\t%s\tSPAN=%s' % (k,p,s))
