# r10rgg18repro/predict18.py — PREDICT THE BYTE MOVERS **BY NAME** from the
# PRISTINE databases, BEFORE the patched sweep exists.
#
# § genLpFoldDigitsMathValue18 can only change a database that holds a
# GEN-SCOPE localparam param_assign whose Rhs is a FOLDED constant (a plain
# decimal decompile — a source-encoded literal takes the other arm).  The
# DATABASE-VISIBLE half of that set is exact: a fold whose shipped digits are
# the SIGNED reading of MSB-set bits prints a NEGATIVE decompile, and every one
# of those moves.  The other half — a fold that OVERFLOWED its declared width,
# where the shipped digits are the truncated value — is NOT database-visible
# (the truncated value looks like any other), so this predictor reports it as a
# separate CANDIDATE class: every gen-scope folded constant, which is the
# superset the mover set must live inside.
#
# REACH is measured and printed: a predictor that restored nothing must not
# read as "0 movers predicted".
import sys, os, glob, subprocess, collections, re
CEN = '/tmp/r10rgg18_pacensus'
# FENCED skip: the four slang-fenced tests are never dispatched and are never
# NAMED in a probe artifact (canaudit.sh reads a bare name as a FENCE-BREACH).
# The fence is written the way boundary18.sh writes it -- all four together,
# case-insensitively -- which is the fence itself, not a dispatch.
FENCE = re.compile(r'unsignedparam|hierpatheval|filelocalparam|topparam')
def fenced(name):
    return bool(FENCE.search(name.lower()))
def scan(db):
    try:
        r = subprocess.run([CEN, db, 'X'], capture_output=True, text=True, timeout=900)
    except subprocess.TimeoutExpired:
        return None
    if r.returncode != 0:
        return None
    neg, cand = 0, 0
    for ln in r.stdout.splitlines():
        if '\t||\t' not in ln:
            continue
        k, v = ln.split('\t||\t', 1)
        if 'RK=constant' not in v:
            continue
        # a GEN-SCOPE carrier: the owning scope path carries a `[` index or the
        # param_assign's own scope is a gen scope; the DEF-view copies (ROOT=
        # param_assign) are counted too, they move with their ELAB twins.
        dec = ''
        for part in v.split('RHS=C{', 1)[-1].split(','):
            if part.startswith('dec='):
                dec = part[4:]
        if not dec:
            continue
        if dec.lstrip('-').isdigit():
            cand += 1
            if dec.startswith('-'):
                neg += 1
    return neg, cand
def main(workdir, out):
    rows = []
    reach_ok = reach_fail = 0
    for mode in ('default', 'testflags'):
        for d in sorted(glob.glob(os.path.join(workdir, mode, '*'))):
            db = os.path.join(d, 'slang.uhdm')
            if not os.path.isfile(db):
                continue
            name = os.path.basename(d).rsplit('-', 1)[0]
            if fenced(name):
                continue
            r = scan(db)
            if r is None:
                reach_fail += 1
                rows.append((mode, name, 'UNREADABLE', 0, 0))
                continue
            reach_ok += 1
            neg, cand = r
            rows.append((mode, name, 'ok', neg, cand))
    with open(out, 'wt') as f:
        f.write("REACH restored=%d unreadable=%d (FENCED tests skipped, never named)\n"
                % (reach_ok, reach_fail))
        pred = [r for r in rows if r[3] > 0]
        cands = [r for r in rows if r[4] > 0]
        f.write("PREDICTED MOVERS (negative-decompile gen-scope folds): %d\n" % len(pred))
        for m, n, s, neg, cand in sorted(pred):
            f.write("  PREDICT %s/%s negdec=%d foldconsts=%d\n" % (m, n, neg, cand))
        f.write("CANDIDATE SET (any gen-scope folded decimal constant): %d rows\n" % len(cands))
        for m, n, s, neg, cand in sorted(cands):
            f.write("  CAND %s/%s foldconsts=%d negdec=%d\n" % (m, n, cand, neg))
        bad = [r for r in rows if r[2] != 'ok']
        f.write("UNREADABLE: %d\n" % len(bad))
        for m, n, s, _, _ in bad:
            f.write("  UNREADABLE %s/%s\n" % (m, n))
    print("wrote", out)
if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
