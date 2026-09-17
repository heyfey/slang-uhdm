#!/usr/bin/env python3
"""r11u65 A-PRIORI MOVER PREDICTOR.

§ unpackedAliasNetType65 can only change the `vpiNetType` of a DEF-view net
whose DECLARED TYPE is an UNQUALIFIED TYPEDEF NAME carrying at least one
UNPACKED level -- either the typedef's own (`typedef logic [1:0] a_t [4];
a_t a;`) or the declarator's (`v_t v [4];`).  Nothing else in the emitter is
touched, and the law is consulted on the DEF view only.

A pristine DATABASE alone cannot discriminate this population: the grid
measured our pristine emission of it as an `array_typespec`, a NAMED
`logic_typespec`, an UNNAMED `logic_typespec` and NO TYPESPEC AT ALL, in
different cells -- the same four shapes every other net already shows.  The
discriminator is the WRITTEN FORM.  So the prediction is a SOURCE CONSTRUCT
SCAN that names CANDIDATE NET NAMES, intersected with the names the PRISTINE
DATABASE actually carries as DEF-view nets (a name the pristine database does
not hold as a def-view net cannot move).

The scan is a deliberate SUPERSET of the law's reach:
  (a) every `typedef <...> NAME [dims];` contributes NAME to the arm's set of
      unpacked-dim typedef names -- whatever the element kind, so `bit`, `int`,
      `enum` and `struct` typedefs are in it and the law declines every one;
  (b) every `<Name> <ident> [dims]` declaration contributes <ident> -- whatever
      <Name> resolves to, so a type parameter, a scoped `pkg::T` and an enum
      are all in it and the law declines every one;
  (c) every `<T> <ident>` use of a name from (a) contributes <ident>.
It cannot MISS a cell the law can reach; it names many it cannot.

usage: predict65.py <workdir> [--tag=T] [--names <netnames-file>]
  <netnames-file>: lines `<mode>/<armdir> <netname>` for every DEF-view net in
  the arm's pristine database (produced by netnames65.sh).
"""
import hashlib
import os
import re
import sys

KEYWORDS = {
    'logic', 'bit', 'reg', 'wire', 'int', 'integer', 'byte', 'shortint',
    'longint', 'time', 'real', 'shortreal', 'realtime', 'string', 'chandle',
    'event', 'void', 'signed', 'unsigned', 'input', 'output', 'inout', 'ref',
    'const', 'var', 'static', 'automatic', 'localparam', 'parameter', 'typedef',
    'struct', 'union', 'enum', 'packed', 'tagged', 'virtual', 'return',
    'assign', 'always', 'always_ff', 'always_comb', 'always_latch', 'initial',
    'final', 'begin', 'end', 'if', 'else', 'case', 'casex', 'casez', 'for',
    'while', 'do', 'foreach', 'repeat', 'forever', 'genvar', 'generate',
    'endgenerate', 'module', 'endmodule', 'interface', 'endinterface',
    'package', 'endpackage', 'function', 'endfunction', 'task', 'endtask',
    'modport', 'import', 'export', 'default', 'this', 'super', 'new', 'class',
    'endclass', 'extends', 'implements', 'wand', 'wor', 'tri', 'tri0', 'tri1',
    'triand', 'trior', 'trireg', 'uwire', 'supply0', 'supply1', 'posedge',
    'negedge', 'edge', 'or', 'and', 'not', 'xor', 'nand', 'nor', 'xnor',
    'buf', 'assert', 'assume', 'cover', 'property', 'endproperty', 'sequence',
    'endsequence', 'bind', 'defparam', 'specify', 'endspecify', 'table',
    'endtable', 'wait', 'disable', 'break', 'continue', 'unique', 'unique0',
    'priority', 'inside', 'with', 'rand', 'randc', 'protected', 'local',
    'pure', 'context', 'extern', 'forkjoin', 'fork', 'join', 'type', 'begin',
}

RE_TYPEDEF = re.compile(r'\btypedef\b([^;]*);', re.S)
# the DECLARED name of a typedef is the last identifier before the trailing
# bracket run, when there is one: `typedef logic [1:0] a_t [4]`
RE_TD_TAIL = re.compile(r'([A-Za-z_]\w*)\s*((?:\[[^\]]*\]\s*)+)$', re.S)
# `<Name> <ident> [dims]` -- two identifiers separated by REAL whitespace.
RE_NAMED_DIM = re.compile(
    r'(?<![.\w$])([A-Za-z_]\w*)(?:\s*::\s*[A-Za-z_]\w*)?\s+([A-Za-z_]\w*)\s*'
    r'(\[[^\];]*\]\s*)+[;,=]')

HOME = os.path.expanduser('~')
ROOTS = [os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'tests'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'tests')]


def strip_comments(t):
    t = re.sub(r'//[^\n]*', ' ', t)
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return t


def scan_text(t, tdnames, cand):
    """(a)+(b): typedef names with an unpacked dim, and declarator-dim uses."""
    for m in RE_TYPEDEF.finditer(t):
        body = m.group(1).strip()
        tm = RE_TD_TAIL.search(body)
        if tm and tm.group(1) not in KEYWORDS:
            tdnames.add(tm.group(1))
    for m in RE_NAMED_DIM.finditer(t):
        if m.group(1) in KEYWORDS or m.group(2) in KEYWORDS:
            continue
        cand.add(m.group(2))


def scan_uses(t, tdnames, cand):
    """(c): every `<T> <ident>` use of an unpacked-dim typedef name."""
    for td in tdnames:
        for m in re.finditer(r'(?<![.\w$])' + re.escape(td) +
                             r'\s+([A-Za-z_]\w*)\s*[;,=\[]', t):
            if m.group(1) not in KEYWORDS:
                cand.add(m.group(1))


def dir_index():
    idx = {}
    for root in ROOTS:
        for dirpath, _dirs, _files in os.walk(root):
            idx[hashlib.sha1(dirpath.encode()).hexdigest()[:8]] = dirpath
    return idx


def sources_of(cmds, srcdir):
    out = []
    try:
        txt = open(cmds).read()
    except OSError:
        return out
    for line in txt.splitlines():
        if not line.startswith('slang:'):
            continue
        for tok in line.split():
            if tok.endswith(('.sv', '.v', '.svh', '.vh')):
                out.append(tok if os.path.isabs(tok)
                           else os.path.join(srcdir or '.', tok))
    if not out and srcdir:
        for dirpath, _dirs, files in os.walk(srcdir):
            for f in files:
                if f.endswith(('.sv', '.v', '.svh', '.vh')):
                    out.append(os.path.join(dirpath, f))
    return out


def main():
    wd = sys.argv[1]
    tag = ''
    namesfile = None
    args = sys.argv[2:]
    for i, a in enumerate(args):
        if a.startswith('--tag='):
            tag = a[6:]
        elif a == '--names':
            namesfile = args[i + 1]
    dbnames = {}
    if namesfile:
        for line in open(namesfile):
            p = line.split()
            if len(p) == 2:
                dbnames.setdefault(p[0], set()).add(p[1])
    idx = dir_index()
    cands, arms, unresolved, noname = {}, 0, 0, 0
    for root, _dirs, files in os.walk(wd):
        if 'cmds.txt' not in files:
            continue
        arms += 1
        mode = os.path.basename(os.path.dirname(root))
        base = os.path.basename(root)
        test, _, h = base.rpartition('-')
        srcdir = idx.get(h)
        if not srcdir:
            unresolved += 1
        tdnames, cand = set(), set()
        texts = []
        for src in sources_of(os.path.join(root, 'cmds.txt'), srcdir):
            try:
                texts.append(strip_comments(open(src, errors='replace').read()))
            except OSError:
                pass
        for t in texts:
            scan_text(t, tdnames, cand)
        for t in texts:
            scan_uses(t, tdnames, cand)
        if not cand:
            continue
        key = mode + '/' + base
        if namesfile:
            have = dbnames.get(key)
            if have is None:
                noname += 1
                continue
            cand &= have
            if not cand:
                continue
        cands[(test, mode)] = sorted(cand)
    for (test, mode), names in sorted(cands.items()):
        print('CANDIDATE %s %s %s nets=%s' % (tag, test, mode, ','.join(names)))
    print('PREDICT %s arms=%d candidateArms=%d candidateTests=%d '
          'unresolvedDirs=%d armsWithoutDbNames=%d'
          % (tag, arms, len(cands), len({t for t, _ in cands}), unresolved,
             noname))


if __name__ == '__main__':
    main()
