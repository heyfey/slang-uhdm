# r10v100 — adversarial verification of § `parenStmtDelayNamelessRef100`

Verdict: **ACCEPT, unchanged production code**.  BASE is `e30c5b4`; the
implementer patch was applied in fresh worktree `/tmp/wt_v100`.  This directory
is measurement evidence only.  Official `uhdm-cmp` and `verify_golden.py` were
the acceptance authorities.  No baseline CSV was edited and nothing was
integrated.

## Independent rebuild and reproduction

Both binaries were configured and built by the verifier with `-j 2`, copied,
and frozen before any sweep:

* pristine: `4e93b58c9954e569b670437ae459cc7a`
* patched: `59f45b74fd50c43b16b4b0a1c958f72c`

These match the implementer bit-for-bit.  Golden dumps were 23 PASS / 0 FAIL
on each binary; `/bin/false` was 0 PASS / 23 FAIL.

The seven implementer arms were rerun in both default and elaborated views.
All reported FIXED / BROKE / STILL counts reproduced.  In particular a1 and
a6 changed from the 13-line missing-Delay head to official `CMP_EQUAL`, while
the non-parenthesised and intra-assignment fence arm a7 remained `CMP_EQUAL`
and byte-identical.

## Adversarial arms

Four new legal-SV arms vary mechanisms the original grid did not:

* `v100_b1_expr_shapes.sv`: nested parentheses, function call, mintypmax,
  cast, system call, and intra-assignment controls.
* `v100_b2_stmt_kinds.sv`: null, compound, conditional, case, loop, and event
  trigger delayed statements.
* `v100_b3_trivia.sv`: spaces, multiline expressions, and comments around the
  pound / parentheses / expression.
* `v100_b4_scopes.sv`: package-scoped, array-select and concatenated values,
  named fork/begin, and increment statement bodies.

Across 8 new arm-view runs the census found **42 TO-GOLDEN delay cells, 0
BROKE** (21 per view).  b1, b2 and b3 reached official `CMP_EQUAL` after the
patch.  b4 retained an unrelated pre-existing head, but all five delay cells
per view moved exactly to golden.  Trivia exposes dump-only span differences
that official Compare does not read; it produced no pristine-right to
patched-wrong comparator cell.  No verifier production fix was required.

## Full gates

Independent frozen-binary sweeps used `--jobs 2`.  `cmds.txt` path audit was
exact: 1523/1523 Surelog invocations and 1458/1458 uhdm2rtlil invocations used
the intended binary in each sweep.

* Surelog default: 470 equal, 283 slang reject, 25 Surelog fail, 11 unequal,
  5 deferred; testflags: 466 equal, 284 reject, 23 fail, 9 unequal, 5
  deferred, 3 no-database, 2 untranslatable, 1 timeout, 1 no-UHDM.  Pristine
  and patched rows are byte-identical (1588/1588); patched vs committed
  baseline also passes.
* uhdm2rtlil both modes: 679 equal, 50 reject, 2 Surelog fail.  Patched vs
  pristine rows are byte-identical in both modes; testflags vs committed
  baseline passes.
* Byte movers: uhdm2rtlil **0/1358**, selfcheck 1357/1358.  Surelog exactly
  **9/956**, selfcheck 955/956: default BuildUVMPkg, MiniAmiq, Scoreboard,
  SeqDriver, SimpleUVM; testflags BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM.
  This is exactly the a-priori predictor set.
* Predictor: uhdm2rtlil 0/1358 (128 delay controls); Surelog 9/956 (2669
  delay controls, 106 excluded intra/skew-shaped cells), with predicted
  multiplicities 5/10/6/10/7 in default and 5/10/10/7 in testflags.
* Nine-database census reproduces implementer counts exactly: 3,6,4,6,5 and
  3,6,6,5 TO-GOLDEN; every database has AWAY-GOLDEN 0 and STILL 0 in both
  multiset and set scoring.
* Current carried canary script reports Surelog `ok=56 changed=0`, u2r
  `ok=9 changed=0`; ctcan2 and canaudit pass.  The implementer transcript's
  52/8 count predates the final carried MiniAmiq/Rggen additions; CSV rows and
  all named canaries are unchanged.

Official heads reproduce bit-for-bit: SeqDriver and MiniAmiq 13→26 in both
modes; SimpleUVM 108→108 in both; Scoreboard/default 108→108;
BuildUVMPkg 32→32; Earlgrey 216→216; Rggen/default 64→64.  Thus the old
delay-control R0 is cleared and the new visible R0 is the 26-line
`event_stmt` `vpiName` mismatch at `uvm_objection.svh:1276`.

## Wide boundary

From a copy of the entire probe tree, recursively, `.sv` and `.v`, both views:

* per file: LISTED=PROCESSED=3213, MOVED=18, NO_OUTPUT=270,
  RC_PAIRS=6426, RC_DIFF=0, ASYM=0.  Movers are exactly five implementer and
  four verifier arms × two views; no earlier-pass file moves.
* per directory: LISTED=PROCESSED=1454, MOVED=10, NO_OUTPUT=239,
  RC_PAIRS=2908, RC_DIFF=0, ASYM=0.  Four are the two own directories.  The
  six non-own movers are r10buvm9, r10uvm75 and r10uvm76 in two views; every
  one has ORDER_BLIND=0 and zero delay-control diff lines.

The r10buvm9 coin was additionally scored against a freshly built Surelog
golden.  Golden-vs-pristine and golden-vs-patched official logs have the same
head/line counts (default 1/3118, elaborated 1/122094); default logs are byte
identical, and elaborated logs become byte identical after object-ID
normalization.  It is neither toward nor away from golden.

## Residues / R0

No new production residue and no blocker.  R0 is the event statement name:
golden names `->m_events[obj].all_dropped` with base identifier `m_events`;
ours leaves the `event_stmt` nameless.  The carried R2 remains the
`before_export` method-call prefix (SimpleUVM ×2 and Scoreboard/default).
