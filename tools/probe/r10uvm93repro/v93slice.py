import sys, re
# Extract, for every streaming-concat operation (vpiOpType 71/72), the FIRST
# operand's shape, keyed by the operation's source line:col.
def parse(path):
    out=[]
    lines=open(path, errors='replace').read().split('\n')
    # build (indent, text) stack
    stack=[]
    nodes=[]
    for ln in lines:
        s=ln.rstrip('\n')
        if not s.strip(): continue
        ind=len(s)-len(s.lstrip(' '))
        nodes.append((ind,s.strip()))
    n=len(nodes)
    for i,(ind,txt) in enumerate(nodes):
        if not txt.startswith('\\_operation:'): continue
        loc=re.search(r'line:(\d+):(\d+)', txt)
        # scan children at ind+2
        opty=None; operands=[]
        j=i+1
        while j<n and nodes[j][0]>ind:
            if nodes[j][0]==ind+2:
                t=nodes[j][1]
                m=re.match(r'\|vpiOpType:(\d+)', t)
                if m: opty=int(m.group(1))
                if t=='|vpiOperand:':
                    # the next node at ind+2 starting with \_ is the operand
                    k=j+1
                    if k<n: operands.append(k)
            j+=1
        if opty not in (71,72): continue
        if not operands: 
            out.append((loc.group(1) if loc else '?', opty, 'NO-OPERANDS')); continue
        k=operands[0]
        head=nodes[k][1]
        kind=head.split(':')[0].lstrip('\\_')
        # gather its scalar fields
        fields=[]
        base=nodes[k][0]
        j=k+1
        while j<n and nodes[j][0]>base:
            if nodes[j][0]==base+2 and nodes[j][1].startswith('|'):
                t=nodes[j][1]
                if re.match(r'\|(vpiDecompile|vpiSize|UINT|INT|vpiConstType|vpiName|vpiOpType|STRING|REAL):', t):
                    fields.append(t.strip('|'))
            j+=1
        nloc = 'LOC' if 'line:' in head else 'NOLOC'
        nparent='NOPAR'
        j=k+1
        while j<n and nodes[j][0]>base:
            if nodes[j][0]==base+2 and nodes[j][1]=='|vpiParent:': nparent='PAR'
            j+=1
        out.append(( (loc.group(1)+':'+loc.group(2)) if loc else '?', opty, len(operands), kind, nloc, nparent, ';'.join(fields)))
    return out
for p in sys.argv[1:]:
    print('###', p)
    for r in parse(p):
        print('   ', r)
