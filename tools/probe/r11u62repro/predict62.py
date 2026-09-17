#!/usr/bin/env python3
"""r11u62 — the A-PRIORI mover prediction for § ovStructActualOwnEnc62.

SOURCES ONLY.  It never opens a database, so the measured mover set must be a
SUBSET of what it names.  A test is a candidate when its sources declare a
module parameter whose TYPE is a user-defined name (a typedef, possibly
package-qualified — the only way to spell a packed struct/union formal) AND
that same parameter name appears as a NAMED override `.<NAME>(` anywhere in the
test, or the declaring module is instantiated with a POSITIONAL `#(` override.

SUPERSET by construction, three ways over:
  * it does not check that the named typedef really resolves to a packed
    struct/union (a `typedef logic [7:0] byte_t` formal counts too),
  * it does not check the ACTUAL's shape (a bare-decimal or NamedValue actual
    is already golden and cannot move),
  * it does not check that the override is reached by elaboration.

usage: predict62.py <corpus-root> [<corpus-root> ...]
       predict62.py --files a.sv b.sv ...     (the POSITIVE CONTROL)
"""
import os
import re
import sys
import subprocess

# The four SLANG-FENCED test names must never be SPELLED in a committed
# artifact (ops rule; `canaudit.sh` audits exactly that and this predictor's
# committed candidate list breached it on its first run).  The list is read
# from the auditor itself -- the one file licensed to hold it -- so this script
# does not spell them either, and a redacted row still carries its evidence: a
# FENCED= tally with no names.
def fencedNames():
    here = os.path.dirname(os.path.abspath(__file__))
    aud = os.path.join(here, 'canaudit.sh')
    try:
        for ln in open(aud, errors='replace'):
            m = re.match(r'\s*FENCED="([^"]*)"', ln)
            if m:
                return set(m.group(1).split())
    except OSError:
        pass
    return set()


FENCED = fencedNames()

BUILTIN = {
    'int', 'integer', 'logic', 'bit', 'byte', 'shortint', 'longint', 'reg',
    'real', 'shortreal', 'time', 'realtime', 'string', 'type', 'signed',
    'unsigned', 'chandle', 'event', 'void', 'parameter', 'localparam',
}

# `parameter <type> NAME` / `localparam <type> NAME` where <type> is an
# identifier or pkg::identifier that is not a builtin keyword.
DECL = re.compile(
    r'\bparameter\s+((?:[A-Za-z_]\w*\s*::\s*)?[A-Za-z_]\w*)\s+([A-Za-z_]\w*)\s*=')
NAMED_OV = re.compile(r'\.\s*([A-Za-z_]\w*)\s*\(')
POS_OV = re.compile(r'\b([A-Za-z_]\w*)\s*#\s*\(')
MODDECL = re.compile(r'\bmodule\s+([A-Za-z_]\w*)')
COMMENT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)


def srcfiles(root):
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if fn.endswith(('.sv', '.v', '.svh', '.vh')):
                yield os.path.join(dp, fn)


def scan(paths):
    """-> (declared, namedOv, posOvMods, modOfParam)"""
    declared = {}          # (file, module, name) -> (type)
    named = set()
    posmods = set()
    modof = {}             # param name -> declaring module
    for p in paths:
        try:
            txt = COMMENT.sub(' ', open(p, errors='replace').read())
        except OSError:
            continue
        # map an offset to the module declared before it
        mods = [(m.start(), m.group(1)) for m in MODDECL.finditer(txt)]
        for m in DECL.finditer(txt):
            ty = re.sub(r'\s+', '', m.group(1))
            base = ty.split('::')[-1]
            if base in BUILTIN or ty in BUILTIN:
                continue
            cur = ''
            for off, nm in mods:
                if off < m.start():
                    cur = nm
                else:
                    break
            declared[(p, cur, m.group(2))] = ty
            modof[m.group(2)] = cur
        for m in NAMED_OV.finditer(txt):
            named.add(m.group(1))
        for m in POS_OV.finditer(txt):
            posmods.add(m.group(1))
    return declared, named, posmods, modof


def candidates(paths):
    declared, named, posmods, modof = scan(paths)
    out = []
    for (f, mod, nm), ty in sorted(declared.items()):
        if nm in named or mod in posmods:
            out.append((nm, ty, mod, f))
    return out


def main():
    a = sys.argv[1:]
    if a and a[0] == '--files':
        for nm, ty, mod, f in candidates(a[1:]):
            print('CAND %-16s type=%-20s module=%-12s %s' % (nm, ty, mod, f))
        return
    tests = []
    for root in a:
        for d in sorted(os.listdir(root)):
            p = os.path.join(root, d)
            if not os.path.isdir(p):
                continue
            c = candidates(list(srcfiles(p)))
            if c:
                tests.append(d)
                if d in FENCED:
                    continue
                for nm, ty, mod, f in c:
                    print('CAND %-28s %-16s type=%-20s module=%s'
                          % (d, nm, ty, mod))
    shown = [t for t in tests if t not in FENCED]
    print('TESTS %d  (FENCED=%d redacted, never dispatched)'
          % (len(tests), len(tests) - len(shown)))
    for t in shown:
        print('TEST %s' % t)


main()
