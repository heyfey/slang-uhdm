#!/usr/bin/env python3
"""r10earl46 GRID reader — for every gen-scope localparam in the arm, print
BOTH carriers of the INT/UINT encoding, BOTH sides, cell for cell:

    carrier 1 = the `parameter` object's own value  (|INT:v / |UINT:v)
    carrier 2 = the `param_assign` Rhs `constant`   (|INT:v + |vpiConstType)

    usage: grid46.py <g.dump> <o.dump> [instance-suffix, default "[0]"]

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.  Both dumps must already
have uhdm-dump's first line stripped.

WHY BOTH CARRIERS.  ModuleEmit's gen-scope fold writes the decision TWICE (the
`mulDivLp9` visitor on the parameter value, and the `mulDiv9` visitor on the
param_assign constant).  A patch that moves one and not the other trades one
divergence for another, and the cmp head — which sits on the CONSTANT — would
not show it.
"""
import re
import sys
from collections import OrderedDict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): \(([^)]*)\)(.*)$')
OBJN = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
ENC = ('INT', 'UINT', 'BIN', 'HEX', 'OCT', 'DEC', 'STRING', 'REAL', 'SCALAR')


def scan(path, want):
    """want = full-name substring, e.g. 'gen_x[0].'   Returns
       {pname: {'p': (enc,val,signed), 'c': (enc,val,ct,size,dec)}}"""
    out = OrderedDict()
    stack = []                 # [indent, kind, fullname, pendingfield, rec]
    # param_assign Lhs points at a parameter by full name; its Rhs constant is
    # a CHILD of the param_assign.  THE DUMP PRINTS vpiRhs BEFORE vpiLhs, so
    # the Rhs constant must be BUFFERED and bound when the Lhs arrives — the
    # first cut of this reader keyed on an already-seen Lhs and reported
    # "(no param_assign)" for EVERY row, which reads exactly like a design that
    # emits none.
    cur_pa = None
    cur_pa_ind = None
    cur_pa_lhs = None
    cur_pa_rhs = None
    pa_field = None

    def commit():
        nonlocal cur_pa, cur_pa_ind, cur_pa_lhs, cur_pa_rhs, pa_field
        if cur_pa_lhs and cur_pa_rhs is not None:
            out.setdefault(cur_pa_lhs, {})['c'] = cur_pa_rhs
        cur_pa = cur_pa_ind = cur_pa_lhs = cur_pa_rhs = None
        pa_field = None

    with open(path, errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')
            if not line:
                continue
            m = FLD.match(line)
            if m:
                ind, name, val = len(m.group(1)), m.group(2), m.group(3)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if cur_pa_ind is not None and ind <= cur_pa_ind:
                    commit()
                if stack:
                    stack[-1][3] = name
                if cur_pa is not None and ind == cur_pa_ind + 2:
                    pa_field = name
                if not stack:
                    continue
                rec = stack[-1][4]
                if rec is not None:
                    if name in ENC:
                        rec['enc'] = name
                        rec['val'] = val.strip()
                    elif name in ('vpiConstType', 'vpiSize', 'vpiDecompile',
                                  'vpiSigned'):
                        rec[name] = val.strip()
                continue
            m2 = OBJN.match(line)
            if not m2:
                continue
            ind, kind, rest = len(m2.group(1)), m2.group(2), m2.group(3)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if cur_pa_ind is not None and ind <= cur_pa_ind:
                commit()
            parent = stack[-1] if stack else None
            pfield = parent[3] if parent else None
            if pfield in ('vpiParent', 'vpiActual', 'vpiInstance', 'vpiModule'):
                stack.append([ind, kind, None, None, None])
                continue
            mo = OBJ.match(line)
            full = mo.group(3) if mo else None
            rec = None
            if kind == 'param_assign':
                commit()
                cur_pa, cur_pa_ind = True, ind
            elif kind == 'parameter' and full and want in full:
                nm = full.split('.')[-1]
                if cur_pa is not None and pa_field == 'vpiLhs':
                    cur_pa_lhs = nm
                else:
                    rec = out.setdefault(nm, {})['p'] = {}
            elif kind == 'constant' and cur_pa is not None \
                    and pa_field == 'vpiRhs':
                rec = cur_pa_rhs = {}
            stack.append([ind, kind, full, None, rec])
    commit()
    return out


def fmtp(d):
    if not d:
        return '(none)'
    return '%s:%s%s' % (d.get('enc'), d.get('val'),
                        ' signed' if d.get('vpiSigned') == '1' else '')


def fmtc(d):
    if not d:
        return '(no param_assign)'
    return '%s:%s ct%s size=%s dec=%s' % (d.get('enc'), d.get('val'),
                                          d.get('vpiConstType'),
                                          d.get('vpiSize'),
                                          d.get('vpiDecompile'))


def main():
    want = sys.argv[3] if len(sys.argv) > 3 else '[0].'
    g = scan(sys.argv[1], want)
    o = scan(sys.argv[2], want)
    names = list(g) + [n for n in o if n not in g]
    print('%-8s | %-22s | %-22s || %-34s | %-34s | %s' %
          ('PARAM', 'G param value', 'O param value',
           'G pa constant', 'O pa constant', 'VERDICT'))
    nbad = 0
    for n in names:
        gp, op = g.get(n, {}), o.get(n, {})
        pv_g, pv_o = fmtp(gp.get('p')), fmtp(op.get('p'))
        cv_g, cv_o = fmtc(gp.get('c')), fmtc(op.get('c'))
        bad = (pv_g != pv_o) or (cv_g != cv_o)
        if bad:
            nbad += 1
        print('%-8s | %-22s | %-22s || %-34s | %-34s | %s' %
              (n, pv_g, pv_o, cv_g, cv_o, 'DIFF <<<' if bad else 'same'))
    print('\nrows=%d  differing=%d   (instance filter %r)' %
          (len(names), nbad, want))


if __name__ == '__main__':
    main()
