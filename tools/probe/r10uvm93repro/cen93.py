#!/usr/bin/env python3
# r10uvm93 census — reads a uhdm-dump on STDIN and reports
#   (a) every streaming operation (vpiOpType 71/72) with the SHAPE of its first
#       operand (the slice size): the constant's decompile/value/size/consttype
#       and whether the constant carries a LOCATION;
#   (b) a histogram of every constant whose vpiDecompile is NOT purely numeric
#       (the "type-name spelled as a constant" family), keyed decompile+value.
# Pure text over the dump: no UHDM linkage, no object minting.
import sys, re, collections
lines = sys.stdin.read().split('\n')
def ind(l): return len(l) - len(l.lstrip(' '))
streams = collections.Counter()
nonnum  = collections.Counter()
NUM = re.compile(r'^-?[0-9]+$')
for i, l in enumerate(lines):
    s = l.strip()
    if s.startswith('|vpiDecompile:'):
        v = s[len('|vpiDecompile:'):]
        if not NUM.match(v):
            # find the owning node header (nearest preceding \_ at indent-2)
            b = ind(l); j = i-1; hdr='?'
            while j >= 0:
                if lines[j].lstrip().startswith('\\_') and ind(lines[j]) == b-2:
                    hdr = lines[j].strip().split(':')[0].lstrip('\\_'); break
                j -= 1
            # the sibling value line (INT:/UINT:/STRING:...)
            val = ''
            t = i+1
            while t < len(lines) and ind(lines[t]) >= b:
                st = lines[t].strip()
                if ind(lines[t]) == b and re.match(r'^\|(U?INT|STRING|REAL|SCAL):', st):
                    val = st; break
                t += 1
            nonnum[(hdr, v, val)] += 1
    m = re.match(r'^(\s*)\|vpiOpType:(71|72)$', l)
    if not m: continue
    base = len(m.group(1))
    k = i+1; first=None
    while k < len(lines):
        li = lines[k]
        if li.strip()=='' : k+=1; continue
        if ind(li) < base: break
        if ind(li)==base and li.strip()=='|vpiOperand:':
            node = lines[k+1].strip()
            kind = node.split(':')[0].lstrip('\\_')
            loc  = 'LOC' if ' line:' in node else 'NOLOC'
            attrs=[]
            t=k+2
            while t < len(lines) and (ind(lines[t]) > base+1 or lines[t].strip()==''):
                st=lines[t].strip()
                if ind(lines[t])==base+2 and st.startswith('|') and not st.endswith(':'):
                    attrs.append(st)
                t+=1
            first=(kind, loc, ' '.join(a for a in attrs if a.split(':')[0] in
                   ('|vpiDecompile','|vpiSize','|UINT','|INT','|vpiConstType','|vpiOpType')))
            break
        k+=1
    # the stream op's own source line (for keying) — strip file/col, keep line
    hdrj=i-1; hdr='?'
    while hdrj>=0:
        if lines[hdrj].lstrip().startswith('\\_') and ind(lines[hdrj])==base-2:
            hdr=lines[hdrj].strip(); break
        hdrj-=1
    lm = re.search(r'line:(\d+):', hdr)
    streams[('OP'+m.group(2), 'srcline='+(lm.group(1) if lm else '?'),
             first if first else ('<none>','',''))] += 1
print('#### STREAMS (slice-size operand shape)')
for k,c in sorted(streams.items(), key=lambda x:(-x[1],str(x[0]))):
    print(f'{c:6d}  {k[0]} {k[1]}  op0={k[2][0]}/{k[2][1]}  {k[2][2]}')
print('#### NON-NUMERIC vpiDecompile (owner, decompile, value)')
for k,c in sorted(nonnum.items(), key=lambda x:(-x[1],str(x[0]))):
    print(f'{c:6d}  {k[0]:14s} decompile={k[1]!r:24s} {k[2]}')
