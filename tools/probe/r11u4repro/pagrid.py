# r11u4 — GRID READER.  Per interface_inst, one line per param_assign:
#   <iface fullname>  <lhs name>  ovr=<0|1>  rhs=<kind>@<span>  val=<value line(s)>
# Reads the uhdm-dump text; nothing is inferred, every field is quoted from it.
import re, sys

def indent(l): return len(l) - len(l.lstrip(' '))

def blocks(lines, kind):
    i = 0
    while i < len(lines):
        m = re.match(r'^(\s*)\\_%s: (.*)$' % kind, lines[i])
        if m:
            b = indent(lines[i]); j = i + 1; blk = []
            while j < len(lines):
                if lines[j].strip() == '': j += 1; continue
                if indent(lines[j]) <= b: break
                blk.append(lines[j][b:]); j += 1
            yield m.group(2), blk
        i += 1

def children(blk, tag):
    """direct |<tag>: entries of a block -> the following object line + its subtree"""
    out = []
    k = 0
    while k < len(blk):
        if indent(blk[k]) == 2 and blk[k].strip() == '|%s:' % tag:
            head = blk[k+1]; b = indent(head); sub = []
            kk = k + 2
            while kk < len(blk) and indent(blk[kk]) > b: sub.append(blk[kk][b:]); kk += 1
            out.append((head.strip(), sub))
        k += 1
    return out

def field(blk, name, dep=2):
    for l in blk:
        if indent(l) == dep and l.strip().startswith('|%s:' % name):
            return l.strip()[len(name)+2:]
    return None

txt = open(sys.argv[1]).read().split('\n')

# ---- ELIDED-REPEAT RESOLUTION.  uhdm-dump prints an object's children only at
# its FIRST appearance; every later reference to the same object prints one bare
# line.  A reader that trusted the local subtree would score a SHARED (and
# judge-EQUAL) object as an empty one -- that is exactly how this pass's first
# patched build, which shared the definition view's aggregate Rhs instead of
# cloning it, made this scorer print `no-ts` and no value for a cell that
# uhdm-cmp had just declared equal.  Index the fullest subtree seen for each
# object HEAD TEXT (kind + span) and fall back to it when the local one is
# empty.
BYHEAD = {}
for _i, _l in enumerate(txt):
    if '\\_' not in _l:
        continue
    _b = indent(_l); _j = _i + 1; _sub = []
    while _j < len(txt) and (txt[_j].strip() == '' or indent(txt[_j]) > _b):
        if txt[_j].strip() != '':
            _sub.append(txt[_j][_b:])
        _j += 1
    _k = _l.strip()
    if len(_sub) > len(BYHEAD.get(_k, [])):
        BYHEAD[_k] = _sub

for name, blk in blocks(txt, 'interface_inst'):
    m = re.match(r'\S+ \(([^)]*)\)', name)
    ifn = m.group(1) if m else name
    for pah, pasub in children(blk, 'vpiParamAssign'):
        ovr = field(pasub, 'vpiOverriden', 2) or '0'
        lhsn = '?'
        for h, s in children(pasub, 'vpiLhs'):
            mm = re.match(r'\\_parameter: \(([^)]*)\)', h)
            if mm: lhsn = mm.group(1).split('.')[-1]
        rhs = 'NONE'; val = ''; ts = 'no-ts'
        for h, s in children(pasub, 'vpiRhs'):
            if not s:
                s = BYHEAD.get(h.strip(), [])
            for l in s:
                if indent(l) == 2 and l.strip() == '|vpiTypespec:': ts = 'HAS-TS'
            mm = re.match(r'\\_(\w+): ,? ?(.*)$', h)
            kind = mm.group(1) if mm else h
            span = ''
            sm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', h)
            if sm: span = '%s-%s' % (sm.group(1), sm.group(2))
            rhs = '%s@%s' % (kind, span)
            vs = []
            for l in s:
                t = l.strip()
                if re.match(r'\|(UINT|INT|STRING|REAL|SCALAR|vpiDecompile|vpiOpType|vpiSize):', t):
                    vs.append('%s%s' % ('  ' * ((indent(l)-2)//2), t))
            val = ' '.join(x.strip() for x in vs)
        print('%-34s %-6s ovr=%-3s %-7s %-28s %s' % (ifn, lhsn, ovr, ts, rhs, val))
