#!/usr/bin/env python3
"""r10uvm133 — the QUERY-CALL census: every type-query system function cell in
one uhdm-dump, keyed on the cell's START (line:col) and classified by ARGUMENT
KIND.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.

A cell is one of

  KEPT   a `sys_func_call` whose VpiName is one of
         $bits $size $clog2 $high $low $left $right $increment $dimensions
  FOLD   a `constant` sitting where such a call was written

FOLD cells cannot be recognised on their own — a folded query call is an
anonymous constant — so the census is a JOIN: cells are keyed on the START
line:col, which BOTH producers anchor at the `$` of the call, and a start that
carries a KEPT call on one side and a constant on the other is a fold/keep
disagreement.  Starts are read from the dump TREE, so nothing unreachable is
counted (RESUME §9: a Serializer::AllObjects row is not evidence of a
judge-visible object).

ARGUMENT KIND is read off the kept call's first `|vpiArgument:` child:

  type-keyword-var / typedef-ref / literal / name / select / member /
  methodcall / funcall / syscall / expr / none

Usage: qcen133.py <dump> [tag]        rows: tag  start  NAME  STATE  KIND  DETAIL
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): *(\([^)]*\))?(?:, (?:file:\S+, )?line:(\d+):(\d+), endln:(\d+):(\d+))?')
QNAMES = {'$bits', '$size', '$clog2', '$high', '$low', '$left', '$right',
          '$increment', '$dimensions', '$unpacked_dimensions'}

def parse(path):
    return open(path, encoding='utf-8', errors='replace').read().split('\n')

def block(lines, i):
    """indices of the field lines belonging to the object opened at line i"""
    m = OBJ.match(lines[i]); ind = len(m.group(1))
    j = i + 1
    while j < len(lines):
        mm = OBJ.match(lines[j])
        if mm and len(mm.group(1)) <= ind:
            break
        j += 1
    return j

def argkind(lines, i, end):
    """kind of the FIRST |vpiArgument: child of the sys_func_call opened at i"""
    m = OBJ.match(lines[i]); ind = len(m.group(1))
    j = i + 1
    while j < end:
        if lines[j].strip() == '|vpiArgument:' and len(lines[j]) - len(lines[j].lstrip()) == ind + 2:
            mk = OBJ.match(lines[j + 1])
            if not mk:
                return 'none', ''
            k, nm = mk.group(2), (mk.group(3) or '').strip('()')
            e2 = block(lines, j + 1)
            if k == 'hier_path':
                kinds = []
                for t in range(j + 2, e2):
                    mt = OBJ.match(lines[t])
                    if mt and len(mt.group(1)) == len(mk.group(1)) + 2 and lines[t-1].strip() != '|vpiParent:':
                        kinds.append(mt.group(2))
                if 'method_func_call' in kinds:
                    return 'methodcall', nm
                return 'member', nm
            if k in ('method_func_call', 'func_call'):
                return 'methodcall' if k == 'method_func_call' else 'funcall', nm
            if k == 'sys_func_call':
                return 'syscall', nm
            if k == 'constant':
                return 'literal', nm
            if k == 'ref_obj':
                return 'name', nm
            if k in ('bit_select', 'var_select', 'part_select', 'indexed_part_select'):
                return 'select', nm
            if k == 'operation':
                return 'expr', nm
            if k.endswith('_var'):
                return 'typekeyword', nm
            return k, nm
        j += 1
    return 'none', ''

def cells(path):
    lines = parse(path)
    out = []
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m or not m.group(4):
            continue
        # a `\_X:` line right under `|vpiParent:` is the dump's BACK-REFERENCE
        # stub, not an object of the tree — counting it doubles every cell.
        if i and lines[i - 1].strip() == '|vpiParent:':
            continue
        kind, nm = m.group(2), (m.group(3) or '').strip('()')
        start = f'{m.group(4)}:{m.group(5)}'
        if kind == 'sys_func_call' and nm in QNAMES:
            e = block(lines, i)
            ak, an = argkind(lines, i, e)
            out.append((start, nm, 'KEPT', ak, an))
        elif kind == 'constant':
            e = block(lines, i)
            dec = val = ''
            for t in range(i + 1, e):
                s = lines[t].strip()
                if s.startswith('|vpiDecompile:'):
                    dec = s.split(':', 1)[1]
                elif re.match(r'^\|(U?INT|STRING|REAL|SCAL):', s):
                    val = s[1:]
            out.append((start, '-', 'CONST', 'const', f'{val}/dec={dec}'))
    return out

if __name__ == '__main__':
    tag = sys.argv[2] if len(sys.argv) > 2 else ''
    for c in cells(sys.argv[1]):
        print('\t'.join((tag,) + c))
