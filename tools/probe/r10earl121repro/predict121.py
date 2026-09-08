#!/usr/bin/env python3
"""r10earl121 — THE MOVER SET, PREDICTED FROM THE PRISTINE DATABASES ALONE.

  predict121.py <pristine-sweep.tsv> [--elab-modes mode:test,mode:test,...]

MEASUREMENT ONLY.  Reads only `censweep121.sh`'s PRISTINE output, so the
prediction cannot be a restatement of the result.

THE CONDITION, term for term the one the patch checks
(§ genCaPatKeepTagDefView121, src/ModuleEmit.cpp):

  patch term                        census term (cen121's `CA` row)
  --------------------------------  ------------------------------------------
  a gen-scope continuous assign     key starts `gen_scope:`, row kind `CA`
  patFlat9: whole-name Lhs over a    `lhs=ref_obj` (a SELECT is `bit_select` /
    packed struct                     `var_select`, a member Lhs is `hier_path`)
  genCaLhsGenLocal113: `bindVariable``agpar=gen_scope` — the DECLARING scope of
    does not find the target          the Lhs target.  `bindVariable`
                                      (CompileStmt.cpp:3089-3148) knows
                                      function/task/begin/module_inst and
                                      NOTHING else, so a `gen_scope`-declared
                                      target is never found and the writer's own
                                      flatten never runs.
  !elabUhdmView121                  the mode's Surelog command line has no
                                      `-elabuhdm` (`--elab-modes` lists the
                                      pairs to exclude; on the `default` mode
                                      the flag is never passed at all)
  (something to gain)               `ntag=0` — a site already carrying its tags
                                      cannot move

THE ONE TERM THE DATABASE CANNOT SHOW is `genCaLhsGenLocal113`'s NAMESAKE half
(r10vearl113: `bindVariable` binds BY NAME and recurses past `module_inst`, so a
gen-local target whose NAME is also declared in an enclosing module body IS
found).  Its only possible effect here is to make this prediction OVER-count —
it can turn a predicted mover into a decline, never hide one.
"""
import collections
import sys


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = sys.argv[1]
    elab = set()
    if '--elab-modes' in sys.argv:
        for spec in sys.argv[sys.argv.index('--elab-modes') + 1].split(','):
            if spec:
                elab.add(tuple(spec.split(':', 1)))

    move = collections.Counter()
    decline = collections.Counter()
    why = collections.Counter()
    for line in open(path):
        f = line.rstrip('\n').split('\t')
        if len(f) < 5 or f[0] != 'O' or f[3] != 'CA':
            continue
        mode, test, key = f[1], f[2], f[4]
        fields = dict(x.split('=', 1) for x in f[5:] if '=' in x)
        if not key.startswith('gen_scope:'):
            continue
        reason = None
        if fields.get('lhs') != 'ref_obj':
            reason = 'lhs-not-whole-name'
        elif fields.get('agpar') != 'gen_scope':
            reason = 'target-not-gen-local'
        elif fields.get('ntag') != '0':
            reason = 'already-tagged'
        elif (mode, test) in elab:
            reason = 'elabuhdm-mode'
        if reason:
            decline[(mode, test)] += 1
            why[reason] += 1
        else:
            move[(mode, test)] += 1

    print('PREDICT-MOVE  rows=%d sites=%d' % (len(move), sum(move.values())))
    for (mode, test), n in sorted(move.items()):
        print('   %-10s %-28s %d sites' % (mode, test, n))
    print('PREDICT-DECLINE rows=%d sites=%d' %
          (len(decline), sum(decline.values())))
    for reason, n in sorted(why.items()):
        print('   %-24s %d sites' % (reason, n))
    for (mode, test), n in sorted(decline.items()):
        print('   (decline) %-10s %-28s %d sites' % (mode, test, n))
    return 0


if __name__ == '__main__':
    sys.exit(main())
