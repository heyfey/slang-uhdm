#!/usr/bin/env python3
"""r10uvm163 — pred163.py: name the byte movers A PRIORI, from the PRISTINE
databases alone, before the patched sweep is run.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  MEASUREMENT ONLY.

    usage: pred163.py <ct163cen listing> ...      (one per database)
           pred163.py --selftest

A row is a CANDIDATE for § classPropSpecForeignPkgHome163 when, in OUR OWN
pristine database:

  * its holder is a VARIABLE or it is UNPARENTED   (a declaration site; a
    `!`-prefixed holder from ct163cen --all is some other emitter arm's
    object and is skipped), and
  * it carries NO listing today                    (nparam <= 0), and
  * its target `class_defn` is a PACKAGE class     (`<pkg>::<name>`, i.e. it
    contains `::` and does not start with `work@` — Surelog's registry
    spelling, read straight off VpiFullName), and
  * that class_defn is PARAMETERIZED               (cdp > 0), and
  * the DECLARING scope's home package (the first `package(...)` on the
    holder's parent chain; none for a module / $unit / interface home) is NOT
    that package.

THE PREDICTION IS DELIBERATELY A SUPERSET.  A database cannot tell a bare
`G x;` from a suppressed `G#(T) x;`: r10uvm53's § classPkgGenericSpecListing53
narrows BOTH to the generic class's name-token span and gives BOTH an absent
listing, and § classTsDefaultSpecNoParams leaves the bare one absent for good.
Only the SYNTAX says which was written, and the syntax is not in the database.
So every candidate is a database that MAY move; a database with NO candidate
CANNOT move, and that is the half the mover gate needs.

GUARDS:
  * a listing that parsed to zero CELL rows is reported as EMPTY and counted,
    so a predictor that reads nothing cannot print "no movers";
  * --selftest is the positive control: a fixture with two candidates, one
    same-home cell, one $unit-generic cell, one non-parameterized cell, one
    cell that already has a listing, and the two UNPARENTED shapes.
"""
import re
import sys

CELL = re.compile(r'^CELL (.*?) \| nparam=(-?\d+) \| params=(.*?) \| npa=(-?\d+) \| '
                  r'holder=(\S+) \| cdefn=(\S*) \| cdp=(-?\d+) \| home=(.*)$')
PKG = re.compile(r'<package\(([^)]*)\)')
BUILTIN = re.compile(r'^(work@)?(mailbox|process|semaphore)$')


def candidates(lines):
    out = []
    for ln in lines:
        m = CELL.match(ln.rstrip('\n'))
        if not m:
            continue
        key, nparam, cdefn, cdp, home = (m.group(1), int(m.group(2)),
                                         m.group(6), int(m.group(7)), m.group(8))
        if nparam > 0:
            continue
        # THE BUILT-IN BLIND SPOT, and why it is handled here rather than
        # reasoned away.  `mailbox` / `process` / `semaphore` are registered by
        # Surelog under their SHORT name and carry the `work@<name>` class_defn
        # spelling in BOTH databases, so the `<pkg>::<name>` test below cannot
        # see them — yet slang hands the emitter a synthesized `std` PACKAGE
        # home for exactly those three, which is what made this pass's first cut
        # over-fire on `mailbox #(T) m;` in `uvm_pkg::uvm_tlm_fifo`.  They are
        # therefore CANDIDATES here, so the predictor names every database the
        # law's fence has to hold in.
        # It is tested BEFORE the `cdp > 0` parameterization test as well: our
        # `work@mailbox` class_defn carries no Parameters vector at all
        # (cdp=0), so a predictor that filtered on cdp first would have gone on
        # missing the very cell that convicted the first cut.
        if BUILTIN.match(cdefn):
            out.append((key, cdefn, '<builtin-registered-bare>'))
            continue
        if cdp <= 0:
            continue
        if '::' not in cdefn or cdefn.startswith('work@'):
            continue
        # Only DECLARATION sites.  ct163cen --all prefixes a NON-variable
        # holder with `!` (a ref_typespec, a class_defn, a type_parameter, an
        # io_decl ...); those objects are minted by other emitter arms that this
        # law does not touch, and counting them turns a mover prediction into
        # noise (5927 cells instead of 1 on the surelog corpus).
        holder = m.group(5)
        if holder.startswith('!'):
            continue
        genpkg = cdefn.rsplit('::', 1)[0]
        hm = PKG.search(home)
        homepkg = hm.group(1) if hm else None
        # An UNPARENTED class_typespec (holder `-`, a MODULE-scope variable on
        # both sides) has no chain to read a home off, so it is kept as a
        # candidate with an UNKNOWN home rather than silently dropped.  The
        # law's gate leaves module scope untouched (r10uvm53's
        # `!declInInstance53`), so these can only ever OVER-predict.
        if home.strip() == '' or m.group(5) == '-':
            out.append((key, cdefn, '<unparented>'))
            continue
        if homepkg == genpkg:
            continue
        out.append((key, cdefn, homepkg or '<no-package-home>'))
    return out


def selftest():
    f = [
        # candidate: package generic alpha, declared in a $unit class
        'CELL g@1:1|v1@1:9 | nparam=-1 | params= | npa=-1 | holder=class_var | cdefn=al::g | cdp=2 | home=<class_defn(work@h)<design(d)',
        # same home -> Surelog probe 3 hits -> never moves
        'CELL g@2:1|v2@2:9 | nparam=-1 | params= | npa=-1 | holder=class_var | cdefn=al::g | cdp=2 | home=<class_defn(x)<package(al)<design(d)',
        # a $unit generic -> r10uvm53 never suppressed it
        'CELL u@3:1|v3@3:9 | nparam=-1 | params= | npa=-1 | holder=class_var | cdefn=work@u | cdp=1 | home=<class_defn(work@h)<design(d)',
        # not parameterized at all
        'CELL n@4:1|v4@4:9 | nparam=-1 | params= | npa=-1 | holder=class_var | cdefn=al::n | cdp=0 | home=<class_defn(work@h)<design(d)',
        # already carries a listing
        'CELL g@5:1|v5@5:9 | nparam=2 | params=T:int_typespec:,I:int_typespec: | npa=2 | holder=class_var | cdefn=al::g | cdp=2 | home=<class_defn(work@h)<design(d)',
        # a SECOND candidate, cross-package
        'CELL g@6:1|v6@6:9 | nparam=0 | params= | npa=0 | holder=class_var | cdefn=al::g | cdp=2 | home=<class_defn(y)<package(be)<design(d)',
        # an UNPARENTED cell (`--all`): no chain, so it is kept as a candidate
        # with an unknown home rather than dropped
        'CELL g@7:1|-@0:0 | nparam=-1 | params= | npa=-1 | holder=- | cdefn=al::g | cdp=2 | home=',
        # same, but its target is a $unit generic -> still not a candidate
        'CELL u@8:1|-@0:0 | nparam=-1 | params= | npa=-1 | holder=- | cdefn=work@u | cdp=1 | home=',
        # a NON-declaration-site holder (ct163cen --all marks it `!`): skipped
        'CELL g@9:1|r@9:1 | nparam=-1 | params= | npa=-1 | holder=!ref_typespec | cdefn=al::g | cdp=2 | home=<class_defn(work@h)<design(d)',
        # a BUILT-IN generic: `work@mailbox` in the database, `std::mailbox` to
        # slang — a candidate, and the fence must hold for it
        'CELL mailbox@10:1|m@10:9 | nparam=-1 | params= | npa=-1 | holder=class_var | cdefn=work@mailbox | cdp=1 | home=<class_defn(x)<package(al)<design(d)',
    ]
    c = candidates(f)
    want = ['g@1:1|v1@1:9', 'g@6:1|v6@6:9', 'g@7:1|-@0:0', 'mailbox@10:1|m@10:9']
    got = [x[0] for x in c]
    ok = got == want
    print(f'candidates={got}')
    print('SELFTEST ' + ('PASS' if ok else f'FAIL want {want}'))
    return 0 if ok else 1


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    tot = 0
    empty = 0
    for p in sys.argv[1:]:
        try:
            lines = open(p).readlines()
        except OSError as e:
            print(f'READFAIL {p} {e}')
            continue
        if not any(l.startswith('CELL') for l in lines):
            empty += 1
            continue
        c = candidates(lines)
        if c:
            print(f'== {p}  candidates={len(c)}')
            for k, d, h in c:
                print(f'   CAND {k}  generic={d}  declaring-home={h}')
            tot += len(c)
    print(f'-- listings={len(sys.argv)-1} EMPTY={empty} CANDIDATE-CELLS={tot}')
