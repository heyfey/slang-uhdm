#!/usr/bin/env python3
"""r11u89 A-PRIORI MOVER CENSUS — census87.py EXTENDED PER LAW.

r11u87's scanner classifies ONE setter into ONE bucket; this pass writes on
three shapes and a setter can belong to several, so this returns a SET of tags
and reports a histogram per tag.  The three new classes, each the superset of
one law:

  CHN89  § modHopSignedStoreChain89 (LAW A) — the setter's chain contains a
         non-package hop declared with a SIGNED type of one of the three kinds
         `valueRange` reads, reached THROUGH at least one further hop (i.e.
         the law's recursion is what sights it, not the landed declaration
         read).  census87's own `SGN87` is the union of the landed law and
         this one; both are reported.
  WID89  § modWideModuleStoreEnc89 (LAW B) — a non-package hop whose chain
         ends at a `'d` or `'o` literal WRITTEN WIDER THAN 64 BITS.
  OVR89  § modOvrStoreSizeIsTheOverride89 (LAW C) — the setter names a PORT
         parameter (one declared inside a module/interface `#( … )` header),
         which is the only kind a `#()` override can reach, in a file that
         instantiates something with a `#(`.

SUPERSET BY CONSTRUCTION on every axis, exactly as r11u87's: nothing checks
that the PATTERN is module-homed, that the parameter is struct-typed, that the
reduce succeeds, that the flat fold happens, that the instantiation overriding
the port parameter is the one the pattern is read in, or that the operand
carries no typespec.  The measured movers must be a SUBSET of the union.

usage:  census89.py [<corpus dir> ...]      (default: the pinned corpora)
        GRID89=<assembled grid> census89.py --selftest    (positive control)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for cand in (os.path.join(HERE, '..', 'r11u87repro'),
             os.path.expanduser(
                 '~/git-repos/slang-uhdm/tools/probe/r11u87repro'), HERE):
    if os.path.isfile(os.path.join(cand, 'census87.py')):
        sys.path.insert(0, cand)
        break
import census87 as S                                           # noqa: E402
C = S.C

PORTHDR = re.compile(r'#\s*\(')


def port_param_names(t):
    """names declared inside a module/interface `#( … )` header"""
    out = set()
    for m in re.finditer(r'\b(?:module|interface)\b\s+\w+\s*(?:import[^;]*;)?'
                         r'\s*#\s*\(', t):
        i = m.end() - 1
        d, j = 0, i
        while j < len(t):
            if t[j] == '(':
                d += 1
            elif t[j] == ')':
                d -= 1
                if d == 0:
                    break
            j += 1
        for part in C.split_top(t[i + 1:j]):
            mm = re.match(r'^(.*?)\b([A-Za-z_]\w*)\s*=\s*(.+)$', part, re.S)
            if mm:
                out.add(mm.group(2))
            else:
                mm = re.match(r'^.*?\b([A-Za-z_]\w*)\s*$', part, re.S)
                if mm:
                    out.add(mm.group(1))
    return out


def written_width(lit):
    """the width a based literal was WRITTEN with, or 0"""
    m = re.match(r"^\s*(\d*)\s*'", lit)
    if not m or not m.group(1):
        return 0
    try:
        return int(m.group(1))
    except ValueError:
        return 0


def classify89(s, decls, ports, has_inst):
    """the SET of tags for ONE setter"""
    tags = set()
    k87 = S.classify(s, decls)
    if k87 != 'AGREE87':
        tags.add(k87)
    x = S.strip_hop(s)
    if not S.NAME.match(x):
        return tags
    bare0 = x.split('::')[-1].strip()
    if has_inst and bare0 in ports:
        tags.add('OVR89')
    seen = set()
    hops = 0
    for _ in range(8):
        bare = x.split('::')[-1].strip()
        if bare in seen or bare not in decls:
            return tags
        seen.add(bare)
        ty, init, inpkg = decls[bare]
        if hops > 0 and not inpkg and S.ty_signed(ty) is True:
            tags.add('CHN89')          # a SIGNED hop reached through a hop
        nxt = S.strip_hop(init)
        m = S.BASED.match(nxt)
        if m:
            if not inpkg and m.group(1).lower() in ('d', 'o') \
                    and written_width(nxt) > 64:
                tags.add('WID89')
            return tags
        if not S.NAME.match(nxt):
            return tags
        x = nxt
        hops += 1
    return tags


def scan(roots):
    hits, hist = {}, {}
    for root in roots:
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn
                     if d not in ('.git', 'slpp_all', 'slpp_unit')]
            for f in fn:
                if not f.endswith(C.EXTS):
                    continue
                p = os.path.join(dp, f)
                try:
                    t = C.strip_noise(open(p, errors='replace').read())
                except OSError:
                    continue
                if "'{" not in t:
                    continue
                decls = S.param_decls(t)
                ports = port_param_names(t)
                has_inst = bool(PORTHDR.search(t))
                for pre, body in C.spans(t):
                    if not re.search(r'\b(parameter|localparam)\b', pre):
                        continue
                    for el in C.split_top(body):
                        s = C.setter_of(el)
                        tags = classify89(s, decls, ports, has_inst)
                        if not tags:
                            hist['AGREE89'] = hist.get('AGREE89', 0) + 1
                            continue
                        for k in tags:
                            hist[k] = hist.get(k, 0) + 1
                        hits.setdefault(C.testname(root, p), set()).add(
                            '%s: %s' % ('+'.join(sorted(tags)), s[:56]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT this pass's own arms."""
    want = {'w3_chain87': 'CHN89', 'w9_wide89': 'WID89',
            'w5_ovr87': 'OVR89', 'w6_dfp89': 'CHN89',
            'y1_sgnd87': 'SGN87', 'z7_trunc86': 'DEC87'}
    d = os.environ.get('GRID89', os.path.join(HERE, 'grid'))
    seen = {}
    for f in sorted(os.listdir(d)):
        if not f.endswith('.sv'):
            continue
        t = C.strip_noise(open(os.path.join(d, f), errors='replace').read())
        decls = S.param_decls(t)
        ports = port_param_names(t)
        has_inst = bool(PORTHDR.search(t))
        ks = set()
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                ks |= classify89(C.setter_of(el), decls, ports, has_inst)
        seen[f[:-3]] = ks
    ok = True
    for a in sorted(want):
        got = seen.get(a, set())
        print('  %-16s %s' % (a, ' '.join(sorted(got)) or '-'))
        if a not in seen:
            print('  ARM %s not in the grid' % a)
            ok = False
        elif want[a] not in got:
            print('  ARM %s carries no %s — the scanner is blind'
                  % (a, want[a]))
            ok = False
    neg = [a for a, k in sorted(seen.items()) if not k]
    print('  not sighted (%d): %s' % (len(neg), ' '.join(neg[:12])))
    if not neg:
        print('  NEGATIVE CONTROL VACUOUS — no arm is unsighted')
        ok = False
    print('SELFTEST ' + ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--selftest':
        sys.exit(selftest())
    roots = sys.argv[1:] or [
        os.path.expanduser('~/git-repos/uhdm2rtlil/tests'),
        os.path.expanduser('~/git-repos/Surelog/tests'),
    ]
    hits, hist = scan(roots)
    for k in sorted(hist):
        print('%-10s %d' % (k, hist[k]))
    print('--- candidate tests: %d' % len(hits))
    for t in sorted(hits):
        for h in sorted(hits[t]):
            print('  %-34s %s' % (t, h))
