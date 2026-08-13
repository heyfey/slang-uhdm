#!/usr/bin/env bash
# r10svs15 CARRIER CENSUS — an UPPER BOUND, and it says so.
#
#   usage: ./census15.sh            # both corpora
#
# WHAT IT PREDICTS.  § cbEventRefFirstInstance15 can only move a database that
# contains an INTERFACE carrying a NAMED clocking block (`clocking cb @(...);`,
# not `default`/`global`, which emitNamedClockingBlocks skips and which we do not
# emit on an interface at all — arm a3 cell e4).  That is the ONLY object whose
# event ref the law touches.
#
# TWO SUFFICIENT CONDITIONS ARE OMITTED, so this is a NECESSARY-condition filter,
# i.e. an UPPER BOUND on the mover set:
#   * the interface must have MORE THAN ONE elaborated instance — an interface
#     instantiated once has only its def ref and its single home ref, and BOTH
#     were already correct (arm a1 cell c8, arm a2 cell d1's `d1a`).  Instance
#     COUNT is an elaboration fact and is not decidable by grepping sources, so
#     it is deliberately not attempted here;
#   * slang must accept the file (284 surelog-corpus tests are SLANG_REJECT).
# A MODULE's named clocking block is NOT a carrier either, in the other
# direction: we emit none at all (arm a1 cell c6), so nothing there can move.
# THE BYTE VERIFIER IS THE AUTHORITY; this runs FIRST only so its answer is on
# the record before the verifier's is known.
#
# TRAPS ENCODED:
#   * `clocking` also names a MODULE's block, a `default clocking`, and the
#     `clocking` KEYWORD inside a modport item (`modport OP(clocking cb, ...)`),
#     which is a REFERENCE and not a declaration — all three are excluded, the
#     modport form by requiring an `@` before the terminating `;`;
#   * a `clocking` block must be counted only INSIDE an `interface ... endinterface`
#     span, so the file is segmented on those keywords rather than grepped flat;
#   * comments are stripped first — `// clocking` is not a declaration;
#   * the test DIR, not the file, is the unit: a corpus test compiles a filelist.
set -u
ROOT_SL=$HOME/git-repos/Surelog
ROOT_U2R=$HOME/git-repos/uhdm2rtlil/test
export ROOT_SL ROOT_U2R
python3 - <<'PY'
import os, re, glob

IFACE_OPEN = re.compile(r'\binterface\b(?!\s+class\b)')
IFACE_CLOSE = re.compile(r'\bendinterface\b')
# A DECLARATION: `clocking [name] @(...)`.  `default`/`global` are excluded by
# requiring that the token before `clocking` is not one of them; a modport's
# `clocking cb` reference is excluded by requiring the `@`.
CB_DECL = re.compile(r'(\w+)?\s*\bclocking\b([^;@]*)@', re.S)


def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', t)


def carrier(d):
    for root, _, files in os.walk(d):
        for f in sorted(files):
            if not f.endswith(('.sv', '.v', '.svh', '.vh')):
                continue
            try:
                t = strip_comments(open(os.path.join(root, f),
                                        errors='replace').read())
            except OSError:
                continue
            # Segment on interface ... endinterface and search only inside.
            pos = 0
            while True:
                mo = IFACE_OPEN.search(t, pos)
                if not mo:
                    break
                mc = IFACE_CLOSE.search(t, mo.end())
                seg = t[mo.end():mc.start() if mc else len(t)]
                pos = mc.end() if mc else len(t)
                for m in CB_DECL.finditer(seg):
                    prev = (m.group(1) or '').strip()
                    if prev in ('default', 'global'):
                        continue
                    name = ' '.join(m.group(2).split())[:24]
                    return (f, name or '<unnamed>')
    return None


def sweep(label, dirs):
    n = t = 0
    print('== ' + label)
    for d in dirs:
        t += 1
        c = carrier(d)
        if c:
            n += 1
            print('   %-30s %s: clocking %s@(...)'
                  % (os.path.basename(d), c[0], c[1]))
    print('   -> %d of %d test dirs' % (n, t))
    return n


sl = sorted({os.path.dirname(p) for p in
             glob.glob(os.environ['ROOT_SL'] + '/tests/*/*.sl') +
             glob.glob(os.environ['ROOT_SL'] + '/third_party/tests/*/*.sl')})
u2r = sorted(p for p in glob.glob(os.environ['ROOT_U2R'] + '/*')
             if os.path.isdir(p))
a = sweep('surelog corpus (one dir per <Name>.sl)', sl)
b = sweep('uhdm2rtlil corpus', u2r)
print('UPPER BOUND: %d test dirs across both corpora.' % (a + b))
PY
