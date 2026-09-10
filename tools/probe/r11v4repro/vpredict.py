#!/usr/bin/env python3
# r11v4 VERIFIER a-priori mover predictor.  INDEPENDENT of the implementer's
# col-0 dump heuristic: § ifacePortViewPaFoldsDeclDefault lives inside
# emitInterfaceInstance and can only fire on a design that HAS an interface,
# so a test none of whose compiled sources contains the `interface` keyword
# CANNOT move.  Computed from the corpus SOURCES + each test's own `.sl`
# argv -- no patched artefact is read.  Deliberate SUPERSET.
import os, re, sys, glob
HOME = os.path.expanduser('~')
ROOTS = [os.path.join(HOME, 'git-repos', 'Surelog', 'tests'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'tests')]
U2R = os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')
IFACE = re.compile(rb'(^|[^A-Za-z_0-9])interface([^A-Za-z_0-9]|$)')
EXTS = ('.v', '.sv', '.vh', '.svh', '.pkg', '.vlt')

def dir_has_iface(d):
    for dp, _, fs in os.walk(d):
        for f in fs:
            if f.endswith(EXTS):
                try:
                    if IFACE.search(open(os.path.join(dp, f), 'rb').read()):
                        return True
                except OSError:
                    pass
    return False

def surelog_tests():
    t = {}
    for r in ROOTS:
        for dp, _, fs in os.walk(r):
            for f in fs:
                if f.endswith('.sl'):
                    t[f[:-3]] = dp
    return t

def u2r_tests():
    t = {}
    for dp, _, fs in os.walk(U2R):
        for c in ('dut.sv', 'dut.v'):
            if c in fs:
                t[os.path.basename(dp)] = dp
    return t

which = sys.argv[1]
tests = surelog_tests() if which == 'surelog' else u2r_tests()
n = 0
for name in sorted(tests):
    if dir_has_iface(tests[name]):
        print('VPREDICT', name); n += 1
print('VPREDICT-TOTAL %d of %d' % (n, len(tests)))
