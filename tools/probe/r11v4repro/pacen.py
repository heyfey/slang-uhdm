# v11u4 VERIFIER census — COMPARE-VISIBLE ONLY.
#   usage: pacen.py <uhdm-dump text>
# Per (interface_inst fullname, param name) emits the whole param_assign Rhs
# subtree flattened, with every field the generated Compare bodies DO read and
# nothing they do not: object KIND, vpiName/vpiDefName, vpiOpType,
# vpiDecompile, vpiSize, the value line, vpiConstType, vpiOverriden, and the
# PRESENCE + actual kind/name of a vpiTypespec.  Spans, ids, vpiFullName,
# vpiParent and file names are stripped -- expr::Compare reads VpiDecompile,
# VpiSize and Typespec; BaseClass::Compare reads VpiType/VpiName/VpiDefName;
# no generated Compare reads a span or a parent.
import re, sys

KEEP = re.compile(r'^\|(vpiOpType|vpiDecompile|vpiSize|vpiConstType|vpiName|'
                  r'vpiDefName|vpiOverriden|vpiLocalParam|vpiSigned|vpiVisibility|'
                  r'UINT|INT|STRING|REAL|SCALAR|BIN|HEX|OCT):')

def indent(l): return len(l) - len(l.lstrip(' '))

def strip_head(h):
    # "\_operation: , line:4:39, endln:4:49"  ->  "operation"
    # "\_parameter: (work@tif.CFG), line:.."  ->  "parameter(CFG)"
    m = re.match(r'\\_(\w+):\s*(\([^)]*\))?', h.strip())
    if not m:
        return h.strip()
    # the parenthesised part of a dump head is the SYNTHESISED vpiFullName,
    # which no generated Compare reads -- drop it.  A real vpiName/vpiDefName
    # is printed on its own |vpiName:/|vpiDefName: line and is kept by KEEP.
    return m.group(1)

def subtree(lines, i):
    b = indent(lines[i]); j = i + 1; out = []
    while j < len(lines):
        if lines[j].strip() == '':
            j += 1; continue
        if indent(lines[j]) <= b:
            break
        out.append(lines[j]); j += 1
    return out, j

txt = [l for l in open(sys.argv[1]).read().split('\n')]

# index full subtrees by head text so an ELIDED repeat can be resolved; the
# head text carries no id for most kinds, so a collision is possible -- the
# index therefore keeps the LONGEST subtree and the caller only uses it when
# the local subtree is empty (a true elision).
BY = {}
for i, l in enumerate(txt):
    if '\\_' not in l:
        continue
    sub, _ = subtree(txt, i)
    k = l.strip()
    if len(sub) > len(BY.get(k, [])):
        BY[k] = sub

def flatten(head, sub, depth, base, acc):
    acc.append('%s%s' % ('.' * depth, strip_head(head)))
    if not sub:
        sub = BY.get(head.strip(), [])
        if sub:
            base = indent(sub[0]) if sub else base
    k = 0
    while k < len(sub):
        l = sub[k]
        t = l.strip()
        d = indent(l)
        if KEEP.match(t):
            acc.append('%s%s' % ('.' * depth, t))
            k += 1
        elif t.startswith('|vpiTypespec:') or t.startswith('|vpiActual:') or \
             t.startswith('|vpiOperand:') or t.startswith('|vpiPattern:') or \
             t.startswith('|vpiRhs:'):
            tag = t.strip('|:')
            if k + 1 < len(sub):
                h = sub[k + 1]
                s2, _ = subtree(sub, k + 1)
                acc.append('%s<%s>' % ('.' * depth, tag))
                flatten(h, s2, depth + 1, indent(h), acc)
                k += 1 + len(s2) + 1
            else:
                k += 1
        else:
            k += 1

for i, l in enumerate(txt):
    m = re.match(r'^\s*\\_interface_inst: \S+ \(([^)]*)\)', l)
    if not m:
        continue
    ifn = m.group(1)
    blk, _ = subtree(txt, i)
    b0 = indent(l) + 2
    k = 0
    while k < len(blk):
        if indent(blk[k]) == b0 and blk[k].strip() == '|vpiParamAssign:':
            h = blk[k + 1]
            pasub, _ = subtree(blk, k + 1)
            # lhs name
            nm = '?'
            ovr = '0'
            for x in pasub:
                if indent(x) == indent(h) + 2 and x.strip().startswith('|vpiOverriden:'):
                    ovr = x.strip().split(':')[1]
            j = 0
            while j < len(pasub):
                if indent(pasub[j]) == indent(h) + 2 and pasub[j].strip() == '|vpiLhs:':
                    mm = re.match(r'\s*\\_\w+: \(([^)]*)\)', pasub[j + 1])
                    if mm:
                        nm = mm.group(1).split('.')[-1]
                j += 1
            acc = []
            j = 0
            while j < len(pasub):
                if indent(pasub[j]) == indent(h) + 2 and pasub[j].strip() == '|vpiRhs:':
                    hh = pasub[j + 1]
                    s2, _ = subtree(pasub, j + 1)
                    flatten(hh, s2, 0, indent(hh), acc)
                    break
                j += 1
            print('%s|%s|ovr=%s|%s' % (ifn, nm, ovr, ' '.join(acc)))
            k += 1 + len(pasub)
        else:
            k += 1
