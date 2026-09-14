#!/usr/bin/env python3
"""r11u21 L2 — the PRISTINE-DATABASE-keyed a-priori mover prediction.

The law's own observable signature in a PRISTINE database:
  (a) some `param_assign` Rhs is a `BIN:` constant whose typespec Actual is a
      `struct_typespec` -- the ASSEMBLED function-built struct parameter this
      family folds off (§ pkgStructFuncAssembleBin / § modStructFuncAssembleBin
      / § asmEncFollowsRef);
  (b) somewhere in the same database a `hier_path` is named `<that parameter>.`
      -- the member read whose elaborated `param_assign` Rhs this pass folds
      (the DEFINITION listing keeps the symbolic path even where the elaborated
      one already folded, so a NESTED read is caught here too).

    predL2_21.py <workdir> [<workdir> ...]
Each workdir is a `verify_golden.py --workdir`; every `slang.uhdm` under it is
dumped and tested.  Databases larger than MAXMB (default 300) or whose dump
times out are listed as SKIPPED BY NAME -- a census zero from this detector is
only a reading for the rest.
"""
import os, re, subprocess, sys

UD = os.environ.get('UHDM_DUMP',
                    os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
MAXMB = float(os.environ.get('MAXMB', '300'))
TMO = float(os.environ.get('TMO', '180'))

PA = re.compile(r'^\s*\\_param_assign: ')
LHSP = re.compile(r'^\s*\\_(?:type_)?parameter: \(([^)]*)\)')
HP = re.compile(r'\\_hier_path: \(([A-Za-z_][\w$]*)\.')

def detect(dump):
    lines = dump.split('\n')
    asm = set()
    n = len(lines)
    i = 0
    def ind(s):
        return len(s) - len(s.lstrip(' '))
    while i < n:
        if PA.match(lines[i]):
            base = ind(lines[i])
            j = i + 1
            binConst = False
            structTs = False
            lhs = None
            while j < n and (lines[j].strip() == '' or ind(lines[j]) > base):
                t = lines[j].strip()
                if t.startswith('|BIN:'):
                    binConst = True
                if t.startswith('\\_struct_typespec:'):
                    structTs = True
                if lines[j].strip() == '|vpiLhs:' and j + 1 < n:
                    m = LHSP.match(lines[j + 1])
                    if m:
                        lhs = m.group(1).split('.')[-1]
                j += 1
            if binConst and structTs and lhs:
                asm.add(lhs)
            i = j
            continue
        i += 1
    if not asm:
        return None
    hits = sorted({b for b in HP.findall(dump) if b in asm})
    return hits or None

def main():
    skipped = []
    for wd in sys.argv[1:]:
        for dirpath, _d, files in os.walk(wd):
            if 'slang.uhdm' not in files:
                continue
            p = os.path.join(dirpath, 'slang.uhdm')
            name = os.path.basename(dirpath)
            mode = os.path.basename(os.path.dirname(dirpath))
            if os.path.getsize(p) > MAXMB * 1e6:
                skipped.append('%s/%s(size)' % (mode, name))
                continue
            try:
                out = subprocess.run([UD, p], capture_output=True, timeout=TMO)
            except subprocess.TimeoutExpired:
                skipped.append('%s/%s(timeout)' % (mode, name))
                continue
            hits = detect(out.stdout.decode('utf-8', 'replace'))
            if hits:
                print('%s %s <- %s' % (mode, name, ' '.join(hits)))
    if skipped:
        print('[SKIPPED] ' + ' '.join(skipped))

main()
