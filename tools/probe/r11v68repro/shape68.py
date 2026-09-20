#!/usr/bin/env python3
"""r11u49 SHAPE LISTER — for each uhdm-dump file, list every param_assign in
every top-level listing (allPackages / topPackages / allModules / topModules)
whose Rhs is an operation, reporting: the listing, the Lhs parameter name, the
op type, the op-level vpiTypespec's ACTUAL (kind+name, '-' when absent), and
the operand shape by kind with each bare constant's vpiSize.
usage: shape.py <dump.txt> [<dump2.txt> ...]"""
import re, sys

def ind(l):  return len(l) - len(l.lstrip())

def block(lines, i, base):
    """the lines strictly deeper than `base`, starting at i"""
    out = []
    while i < len(lines):
        l = lines[i]
        if l.strip() and ind(l) <= base: break
        out.append(l); i += 1
    return out, i

def actual_of(blk, base):
    """given the lines under a |vpiTypespec:/|vpiActual: label at depth base,
    the first child object's kind(name)"""
    for l in blk:
        if ind(l) == base and l.lstrip().startswith('\\_'):
            m = re.match(r'\\_(\w+): (\(([^)]*)\))?', l.lstrip())
            if m: return m.group(1), (m.group(3) or '')
    return None, None

def parse(path):
    lines = open(path, errors='replace').read().splitlines()
    sect = None; out = []
    for i, ln in enumerate(lines):
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m: sect = m.group(1)
        m = re.match(r'^(\s*)\\_param_assign: , (line:[\d:]+)', ln)
        if not m: continue
        lines[i] = ln + '\x00' + (sect or '?')
    sect = None
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m: sect = m.group(1); i += 1; continue
        m = re.match(r'^(\s*)\\_param_assign: , (line:[\d:]+)', ln)
        if not m: i += 1; continue
        pind = ind(ln); loc = m.group(2)
        blk, i = block(lines, i + 1, pind)
        name = '?'; rhs_at = None
        label = None
        for a, l in enumerate(blk):
            if ind(l) != pind + 2: continue
            s = l.lstrip()
            if s.startswith('|'): label = s.split(':', 1)[0]; continue
            if s.startswith('\\_') and label == '|vpiLhs':
                mm = re.search(r'\\_parameter: \(([^)]*)\)', s)
                if mm: name = mm.group(1)
            if s.startswith('\\_') and label == '|vpiRhs':
                rhs_at = a
        if rhs_at is None or not blk[rhs_at].lstrip().startswith('\\_operation:'):
            out.append((sect, name, loc, 'RHS-NOT-OPERATION')); continue
        rind = ind(blk[rhs_at])
        rblk, _ = block(blk, rhs_at + 1, rind)
        ts = '-'; op = '?'; ops = []
        label = None
        a = 0
        while a < len(rblk):
            l = rblk[a]
            if ind(l) != rind + 2: a += 1; continue
            s = l.lstrip()
            if s.startswith('|'):
                label = s.split(':', 1)[0]
                if label == '|vpiOpType': op = s.split(':', 1)[1].strip()
                a += 1; continue
            if s.startswith('\\_'):
                sub, _ = block(rblk, a + 1, rind + 2)
                kind = re.match(r'\\_(\w+):', s).group(1)
                if label == '|vpiTypespec':
                    lab2 = None
                    for l2 in sub:
                        if ind(l2) != rind + 4: continue
                        s2 = l2.lstrip()
                        if s2.startswith('|'): lab2 = s2.split(':',1)[0]; continue
                        if s2.startswith('\\_') and lab2 == '|vpiActual':
                            mm = re.match(r'\\_(\w+): (\(([^)]*)\))?', s2)
                            ts = mm.group(1) + '(' + (mm.group(3) or '') + ')'
                            break
                elif label == '|vpiOperand':
                    if kind == 'constant':
                        # r11u61: the payload is ENCODING-VISIBLE.  A lister that
                        # prints only vpiSize cannot see a UINT written where
                        # golden wrote a BIN of the same width — which is exactly
                        # how the rp32_r5p_alu / _wbu regression hid from the
                        # first cut of this pass's grid.  vpiSize, vpiConstType
                        # and the VALUE all ride in the cell.
                        sz = '?'; ct = '?'; val = ''
                        for l2 in sub:
                            s2 = l2.lstrip()
                            if s2.startswith('|vpiSize:'):
                                sz = s2.split(':', 1)[1].strip()
                            elif s2.startswith('|vpiConstType:'):
                                ct = s2.split(':', 1)[1].strip()
                            elif re.match(r'\|(UINT|INT|DEC|BIN|HEX|OCT|STRING|REAL|SCALAR):', s2):
                                val = s2[1:].strip()
                        ops.append('const/%s@%s=%s' % (sz, ct, val))
                    elif kind == 'operation':
                        ot = '?'
                        for l2 in sub:
                            if ind(l2) == rind + 4 and l2.lstrip().startswith('|vpiOpType:'):
                                ot = l2.split(':',1)[1].strip(); break
                        ops.append('op' + ot)
                    else:
                        mm = re.match(r'\\_\w+: (\(([^)]*)\))?', s)
                        ops.append(kind + ('(' + (mm.group(2) or '') + ')' if mm and mm.group(2) else ''))
            a += 1
        out.append((sect, name, loc, 'op=%s ts=%s ops=[%s]' % (op, ts, ' '.join(ops))))
    return out

if __name__ == '__main__':
    for p in sys.argv[1:]:
        print('## ' + p)
        for sect, name, loc, d in parse(p):
            print('  %-16s %-34s %-14s %s' % (sect or '?', name, loc, d))
