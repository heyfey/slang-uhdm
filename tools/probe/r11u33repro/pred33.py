#!/usr/bin/env python3
"""r11u33 — PREDICT THE MOVER SET BY NAME, FROM THE PRISTINE DATABASES.

    pred33.py <workdir>            # a verify_golden workdir (mode/<name>-<hash>/)

Streams every pristine `slang.uhdm` through `uhdm-dump` and reports the tests
whose database carries one of the TWO SIGNATURES § rangeBoundReduceEnc33 can
move.  LHS is always golden elsewhere; this tool reads OUR side only, because
the question is which of OUR objects the law rewrites.

  SIGNATURE B (the unpacked RANGE-DIM site).  A range bound that is a constant
  with `vpiConstType:7` AND `vpiSize:64`.  That is the blanket `INT:<v>`/64
  the arm being replaced minted for EVERY non-literal bound; a literal bound
  never reaches it (it is emitted `UINT` ct 9), so the signature is exactly the
  arm's own output.

  SIGNATURE A (the packed-dim site).  A range bound that is an `operation` with
  `vpiOpType:24` (vpiAddOp) — the DEF-view twin of the ELAB constant whose
  size the law re-stamps.  Only the ADD arm moves there.

Both OVER-predict on purpose: a signature says the law REACHES the design, not
that it changes a byte (it abstains whenever it cannot size a leaf).  What the
set is for is the other direction — a database that moves and is NOT in it is
an unpredicted mover and the pass has to explain it.

POSITIVE CONTROL: `--selftest <dump>` re-runs the scan over a dump with one
bound deliberately rewritten, so a scan that can see nothing cannot read as a
clean census.
"""
import os
import re
import subprocess
import sys

DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
SIDE = re.compile(r'^\s*\|vpi(Left|Right)Range:\s*$')
OPEN = re.compile(r'^(\s*)\\_([a-z_]+):')
FLD = re.compile(r'^\s*\|(vpiSize|vpiConstType|vpiOpType):(-?\d+)\s*$')


def scan_text(lines):
    """Returns (hasB, hasA)."""
    hasB = hasA = False
    armed = False          # the next \_ open is a range BOUND
    cur = None             # ('constant'|'operation', indent, {fields})
    for ln in lines:
        if SIDE.match(ln):
            armed = True
            continue
        m = OPEN.match(ln)
        if m:
            ind, kind = len(m.group(1)), m.group(2)
            if armed and kind in ('constant', 'operation'):
                cur = [kind, ind, {}]
            elif cur is not None and ind <= cur[1]:
                cur = None
            armed = False
            continue
        if cur is not None:
            m = FLD.match(ln)
            if m:
                cur[2][m.group(1)] = int(m.group(2))
                if cur[0] == 'constant' and cur[2].get('vpiConstType') == 7 \
                        and cur[2].get('vpiSize') == 64:
                    hasB = True
                if cur[0] == 'operation' and cur[2].get('vpiOpType') == 24:
                    hasA = True
        if hasA and hasB:
            break
    return hasB, hasA


def main():
    if sys.argv[1] == '--selftest':
        src = open(sys.argv[2], encoding='utf-8', errors='replace').read()
        base = scan_text(src.splitlines())
        # the control: strip every ct7 bound and every op24 so the scan MUST
        # go quiet, then put one of each back.
        off = [l for l in src.splitlines()
               if '|vpiConstType:7' not in l and '|vpiOpType:24' not in l]
        print('POSCONTROL base=%s stripped=%s' % (base, scan_text(off)))
        return
    wd = sys.argv[1]
    for mode in sorted(os.listdir(wd)):
        md = os.path.join(wd, mode)
        if not os.path.isdir(md):
            continue
        for d in sorted(os.listdir(md)):
            u = os.path.join(md, d, 'slang.uhdm')
            if not os.path.isfile(u):
                continue
            name = d.rsplit('-', 1)[0]
            try:
                p = subprocess.run([DUMP, u], capture_output=True, text=True,
                                   timeout=300)
            except subprocess.TimeoutExpired:
                print('%s\t%s\tDUMP-TIMEOUT' % (mode, name))
                continue
            b, a = scan_text(p.stdout.splitlines())
            if b or a:
                print('%s\t%s\t%s%s' % (mode, name, 'B' if b else '',
                                        'A' if a else ''))


if __name__ == '__main__':
    main()
