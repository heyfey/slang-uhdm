#!/usr/bin/env python3
"""r10uvm212 — A-PRIORI MOVER PREDICTION from PRISTINE databases.

MEASUREMENT ONLY.  The official `uhdm-cmp` is the sole judge; nothing here
decides acceptance.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

§ classTdCloneTakesTheBasesEmptyListing212 changes EXACTLY the class_typespecs
that, in a PRISTINE database, are

    * a CLONE: they carry a `vpiTypedefAlias` whose actual is a class_typespec,
    * with a NON-NULL `Parameters` of their own,
    * whose BASE's `Parameters` is a NULL vector.

`ct212alias` prints one `MISMATCH` line per such object.  This script runs it
over EVERY `slang.uhdm` in one or more verify_golden workdirs and prints the
predicted mover set BY DATABASE and BY OBJECT NAME, so the prediction is on
record BEFORE the patched sweep exists.

  usage: pred212.py <ct212alias> <workdir> [<workdir> ...]

A workdir with no databases prints `SCANNED=0` and exits non-zero: a screen that
reaches nothing must never read as "no movers".
"""
import os
import subprocess
import sys


def main() -> int:
    if len(sys.argv) < 3:
        sys.stderr.write("usage: pred212.py <ct212alias> <workdir> ...\n")
        return 2
    tool = sys.argv[1]
    if not os.access(tool, os.X_OK):
        sys.stderr.write("FATAL: %s is not executable\n" % tool)
        return 3
    scanned = 0
    hits = 0
    for root in sys.argv[2:]:
        for dirpath, _dirs, files in os.walk(root):
            if 'slang.uhdm' not in files:
                continue
            db = os.path.join(dirpath, 'slang.uhdm')
            scanned += 1
            try:
                out = subprocess.run([tool, db], capture_output=True, text=True,
                                     timeout=600).stdout
            except subprocess.TimeoutExpired:
                print('TIMEOUT %s' % db)
                continue
            # ct212alias's HEADER line also contains the word MISMATCH
            # ("clone/base listing MISMATCHES=0"), and a bare substring test
            # made every one of the 956 clean databases report a mover.  Only
            # the `x<count> MISMATCH ...` DATA rows count.
            bad = [ln for ln in out.splitlines()
                   if ln.startswith('x') and ' MISMATCH ' in ln]
            if not bad:
                continue
            # `<workdir>/<mode>/<Name>-<hash>` -> "Name/mode"
            row = os.path.basename(dirpath).rsplit('-', 1)[0]
            mode = os.path.basename(os.path.dirname(dirpath))
            for ln in bad:
                hits += 1
                print('PREDICTED-MOVER %-24s %-10s %s' % (row, mode, ln.strip()))
    print('SCANNED=%d PREDICTED-MOVER-OBJECTS=%d' % (scanned, hits))
    return 0 if scanned else 4


if __name__ == '__main__':
    sys.exit(main())
