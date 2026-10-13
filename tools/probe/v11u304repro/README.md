# v11u304 — adversarial verification of r11u304 (pass 304, expression/parameter ground)

Verdict: **ACCEPT WITH FIX.** Every headline number of r11u304 reproduces bit for bit. Fresh cases found two
breaks on legal SystemVerilog where pristine was right and the law moved a record away from golden. Two
refinements behind their own switches fix both. With them in, no fresh, control or gate case-view moves away
from golden. The delivery is /tmp/r11u304.verified.patch: the implementer's patch, plus the two refinements
in src/ExprEmit.cpp and src/R304.h, plus this directory and the regenerated tests/LAWS.md.

Base 1a9530f6 (pass 302). Binaries, each frozen (chmod 555) before it was measured:

| binary | md5 | note |
|---|---|---|
| pristine | aaf89bbe9c28f0fbf51f6ae28021ecfe | equal to the main tree's build/slang-uhdm at the base |
| law | 8e3a7b6bb8169cb9f720d1c82732a382 | built from /tmp/r11u304.patch, equal to the implementer's law binary |
| fix | d3682d41ed6d22713c57981eb8e45751 | law plus the two refinements |

All three link slang 12.0.0+545f88b2e. Every cmds.txt of the pristine, law and fix sweeps names its own
binary (drivers/audit.sh: own 3265, other 0, noslang 50, fenced skipped 8 on each).

## The refinements (src/R304.h; `R11V304_OFF` drops both and gives the law's bytes, `R11U304_OFF` still gives pristine's)

### § hpOpIdxTernTrueKeepsIdxLoc304v — `R11V304_TERNTRUE_OFF` (ExprEmit, § hpOpIdxNestedSelByPath304's walk)

**The break.** § hpOpIdxNestedSelByPath304 spans every nested select in a path index's operation over the
whole select. Golden does that only outside a conditional's TRUE branch. For `ea[c ? k[0] : k[1]].fld`
(cases/VN/vn01_tern_idx), golden names both selects by the path (`work@top.ea[c ?  : ].fld.k`), but:

- k[0], in the true branch, sits at its index (5:28-29), the span pristine already wrote;
- k[1], in the false branch, spans the whole select (5:33-37).

In the elaborated view, golden's definition listing keeps `work@top.k` at 5:28-29, which pristine also had.
The law moved that record to 5:26-30: chain away 1. The law's first record there reads `col`, against
pristine's `fullname`.

**The decode, from 15 fresh case dirs:**

- vn23: the select in the condition spans whole.
- vn25: a select in the false branch spans whole.
- vn24, vn27, vn28, vn30, vn36: a select anywhere in the true branch keeps its index span. This holds under
  `+`, inside parentheses, with a variable index, and next to a bare reference.
- vn29: inside a nested conditional in the true branch, both branches keep the index span.
- vn32: a nested conditional in the false branch splits again, true at the index and false whole.
- vn31: the true branch's own nested select is named through it and keeps its index span.
- vn26: the same split holds under `+`.
- vn33: the same split holds in a continuous assignment.
- vn37: the same split holds in an lvalue.
- vn34: the same split holds inside a call.
- vn39: the same split holds in a package function body.

All of these are named exactly as the law names them. This is the call-argument behaviour the law already
models (`inCall304`).

**The refinement.** In the walk over the index operation, and in the nested select's own index walk, the true
operand of a `vpiConditionOp` is walked with the keep-location flag. Names are unchanged. Trace:
`NESTSEL_TERNTRUE <base>`.

**The result.** The refinement moves 14 dirs (28 case-views) off the law's bytes, and 25 of those
case-views enter STRICT_EQUAL. vn01, vn24, vn26 to vn33, vn36 and vn37 enter in both views (24 case-views)
and vn39 enters in its default view (1). The other three case-views are vn35 d/e (fullname -> fullname, the
residue below) and vn39 e (col -> fullname, an import-clone face).

### § castAliasSignCastRhsNoClone304v — `R11V304_SIGNCAST_OFF` (ExprEmit, § genCaCastTdAliasScopedName304's gate)

**The break.** The law fires when `caBoundLhsOpRhs17` is set. That flag reads slang's expression kind. A
written `signed'(...)` / `unsigned'(...)` right side is a Conversion in slang. In the database, though, it is
a `$signed` / `$unsigned` sys_func_call, in ours and in golden's, and UhdmWriter::writeCont_assign does not
re-clone a sys_func_call right side. So golden keeps the bare `idx_t` for:

```systemverilog
assign y = signed'(idx_t'(a));   // inside if (1) begin : g
```

The law scoped it to `work@top.g.idx_t`. The record moved away from golden in both views (chain away 1) on
three fresh cases:

- vc20_signed_wrap
- vc27_unsigned_wrap
- vc32_signed_of_op (`signed'(idx_t'(a) + 2'd1)`)

vc28 (`(signed'(...))`) moves the same record. It is stage 1 on every binary.

**The refinement.** It finds the assignment's right-side root through the syntax parents, reading through
parentheses. When that root is a `SignedCastExpression`, the re-clone is not counted. A right side that IS the
cast keeps the law's other branch. `signed'(idx_t'(a)) + 3'sd1` (vc29, an operation root) still fires, as
golden scopes it. Trace: `CASTALIAS_SIGNCAST <scope> <type>`.

**The result.** The 8 case-views go back to pristine's bytes.

## Reproduction of the implementer's numbers (all bit for bit)

**Firing census.** drivers/tracecensus.sh ran on the fix binary before the fix sweep (evidence/predict_fix.txt).
It is byte-identical to the implementer's evidence/predict.txt: six probe databases (b1_sites NESTSEL:2,
g213_i_scopedtd TDITEM:2, a1_uninst_if UIPARAMTS:1, c2_idxkind NESTSEL:1, c09_genif_modtd_ctl and
c11_genif_pkimp CASTALIAS:1). It finds no firing or abstention on any corpus row-mode, so neither refinement
fires anywhere in the gate.

**Probe.** Pristine reads 4010 + 77. Law and fix each read 4015 EQUAL + 72 STRICT_NOTEQUAL, with
regressions 0, conversions 5 and changes 1. The fresh rows:

- `r10earl29repro/b1_sites,EQUAL,,equal` (was `differ:fullname(4)`)
- `r10uvm213repro/g213_i_scopedtd,EQUAL,,equal` (was `differ:line(2)`)
- `r10uvm220repro/grid220/a1_uninst_if,EQUAL,,equal` (was `differ:file(2)`)
- `r11u113repro/grid/c/c09_genif_modtd_ctl,EQUAL,,equal` (was `differ:fullname(1)`)
- `r11u113repro/grid/c/c11_genif_pkimp,EQUAL,,equal` (was `differ:fullname(1)`)
- The change `r10uvm79repro/c2_idxkind,STRICT_NOTEQUAL,differ:col(3),differ:col(3)` (was `col(5)`): chain away 0,
  2 records toward golden.

The probe csv diff, law against pristine, is exactly those six rows. Fix against law: 0 lines.

**Corpora.** Surelog reads 480 + 0 (default) and 474 + 0 (testflags). uhdm2rtlil reads 803/1/67 in both
modes. Both corpora show regressions 0, conversions 0 and changes 0 on law and fix. The csv diff against
pristine is only the LowMemLib and LowMemPkg testflags detail text (the workdir path); fix against law,
0 lines.

**Downstream.** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT. The pristine, law and fix csvs
are each byte-identical to results/downstream_uhdm2rtlil.csv.

**byteverify.** Run with tools/probe/r11v75repro/byteverify.sh and SELFCHECK=1 on fence-filtered hard-link
mirrors (drivers/mirror.sh, 2560 databases each, 8 fenced skipped), and drivers/bytecmp.sh for the probe and
downstream-lane databases (path list filtered by $FENCED first). Movers:

| comparison | corpus | probe | downstream lane |
|---|---|---|---|
| law vs pristine | 0 of 2560 | exactly the predicted 6 of 4087 | 0 of 805 |
| fix vs law | 0 | 0 | 0 |
| fix vs pristine | 0 | the same 6 | 0 |

The pristine probe databases compared here come from a second pristine probe run from the law worktree, so
the embedded source paths match. SELFCHECK reads 2559 of 2560 (4086 of 4087, 804 of 805). The self-check
compares every file with one fixed file, and that fixed file compared with its own unmoved twin is the one
not flagged: the artefact pass 201 explained, not a mover.

**Canaries.** tools/probe/r11u107repro/canaries.sh reads surelog ok=52 changed=0 and uhdm2rtlil ok=16
changed=0. ctcan2 PASSES with EXPECT_UNKNOWN=1 and with EXPECT_UNKNOWN=6. This holds on all three sweeps.

**Determinism** (drivers/det.sh, three concurrent draws per row-mode, evidence/determinism.txt). Law and fix
each give one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and
Rggen. The two binaries give the same hashes, equal to the sweeps' hashes and to the implementer's.
Scoreboard and Rggen write no testflags database.

**The implementer's grid** (tools/probe/r11u304repro/cases, 139 dirs, 278 case-views), rerun with my own
golden cache:

- Every verdict, exit code and uhdm-cmp count is equal to their evidence/grid.txt on 2224 of 2224 lines. Only
  the database md5s differ, because the case path is embedded (/tmp/wt_r11u304 against /tmp/wt_v11u304).
- 210 movers, 178 entering STRICT_EQUAL, 0 leaving.
- `R11U304_OFF` equals pristine on 278 of 278.
- Single-switch attribution: CASTALIAS 62, NESTSEL 46, TDBEGIN 42, TDITEM 38, UIPARAMTS 22.
- The fix equals the law on all 278 (evidence/impl_grid_3bin_summary.txt).

**Trigger-selected controls.** drivers/firescan.sh with the fix binary over every dut.sv dir under
tools/probe and tests/probe: 30314 dirs, the path list filtered by $FENCED first. 246 dirs fire. Leaving out
both passes' own cases and the six gate databases, 20 tools/probe dirs fire (evidence/control_trigger_dirs.txt):

- They are the implementer's 19, plus r11v178repro hx/x13_idx_kinds2. There only `NESTSEL_TERNTRUE` traces (a
  conditional in a path index with no nested select), and it moves nothing.
- Law vs pristine, 40 case-views: 32 moving, 9 entering STRICT_EQUAL, 0 leaving, chain away 0 on all 32, 126
  records toward golden (reproduces the implementer).
- Fix vs law: 0 of 40 moving.
- The scan met one segfault (exit 139). The implementer names it v11u112repro m07_hdr_enum_default and reports
  that it crashes on pristine too. The driver does not record which dir crashed, and I did not rerun that case.

**Standard controls** (drivers/controls.sh, pristine vs fix):

- Scope: every case dir of r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11v120repro,
  r11u124repro, r11v124repro, r11u131repro, r11v131repro, r11u145repro, r11v145repro, r11u198repro,
  v11u198repro, r11u282repro, v11u282repro, r11u288repro, v11u288repro, r11u302repro, v11u302repro and
  r11v178repro, plus the target dirs r10earl29repro, r10uvm213repro, r10uvm220repro, r10uvm79repro and
  r11u113repro. That is 2222 dirs and 4444 case-views.
- 8 moving, all 8 entering STRICT_EQUAL, 0 leaving, no exit-code or uhdm-cmp change. The movers are
  r11u198repro K/k10_for_typedef, v11u198repro K/x13_typedef_cast_concat, v11u282repro VC/vc05_cast_typedef_sel
  and r11v145repro bso/x14_bitsel_in_op, each d/e (evidence/controls_std_fix.txt).

## The attack (cases/, 113 dirs, 226 case-views, every line with its exit code; evidence/grid.txt)

drivers/grid3.sh runs pristine, law, fix, fix+R11U304_OFF, fix+R11V304_OFF, and fix with each of the seven
single switches, in both views. The first line of every case names its law.

| dir | law | dirs | shapes |
|---|---|---|---|
| VC | § genCaCastTdAliasScopedName304 (29), § castAliasSignCastRhsNoClone304v (4) | 33 | for-generate select target over the cast, bound concatenation, the cast in a condition, `$unsigned` in an operation, nested casts, a typedef in the generate block, enum and int typedefs, a parameter delay, a generate-local target over an operation, parenthesised select target, a user call in an operation, a package parameter, a child with two overrides, typedef of typedef, a constant cast, `& 2'b11`, an implicit-net target, two casts, `signed'`, `unsigned'`, `(signed'(...))`, `signed'(...) + 1`, `signed'(op)`, a written `$signed`, a genvar typedef range, an interface generate, a member target, an unsized `+ 1`, a case generate, a header parameter range with a genvar operand, replication, `inside` |
| VN | § hpOpIdxNestedSelByPath304 (22), § hpOpIdxTernTrueKeepsIdxLoc304v (17) | 39 | ternary in the index (condition, true, false, nested, under `+`, parenthesised, with a call, in a CA, an lvalue and a nested index), part select, indexed part select, packed bit, a parameter array, unpacked array, two element operations, variable index in the nested select, function and package function bodies, interface-port base, case item, port connection, a struct member in the index, `$clog2`, for-generate, `inside`, a task lvalue, a 2-D select, shift / or, an enum reference, a class property, a package wildcard-import clone |
| VT | § tfBodyTypedefForcesBegin304 (21), § tfBodyTypedefIsItem304 (10) | 31 | one-statement bodies: for, foreach, case, fork, assert, void call, labeled statement, `this.d = new[3]` (the § thisSuperNewAssignNoStmt3 drop), while, `$display`, named block, task output, pure-virtual implementation, if-else, package import item, ref argument, extern with a default argument, interface modport-imported function, a constant function in a localparam, a package wildcard-import clone; list bodies: a block second item, multi-declarator, typedef third (control), typedef pair, import item, a class copy in an importing package |
| VU | § uninstIfaceForeachParamOwnTs304 | 10 | a function-local localparam shadowing the interface parameter, `pk::P` beside an interface `P`, a class in the interface, a struct element, a named block, an interface instantiated only in an uninstantiated module, a loop variable read, a 2-D localparam, a generate-instantiated interface (control), an `always` block |

| binary | movers | entering STRICT_EQUAL | leaving | exit-code changes |
|---|---|---|---|---|
| law | 192 | 108 | 0 | 0 |
| fix | 184 | 133 | 0 | 0 |

- **Switch checks:** fix+R11U304_OFF equals pristine on 226 of 226, and fix+R11V304_OFF equals the law on
  226 of 226.
- **Fix movers by single law switch:** NESTSEL 70, CASTALIAS 44, TDBEGIN 42, TDITEM 16, UIPARAMTS 12. Every
  mover is restored to pristine's bytes by exactly one switch.
- **Fix-vs-law case-views:** 36, each restored to the law by exactly one refinement switch (TERNTRUE 28,
  SIGNCAST 8).
- **Away census** (map 12's chain-keyed census, drivers/awaygrid.sh with strictcmp_x md5
  886f030233ecdbcce7d0e29ac0c4df2c, equal to the implementer's):
  - Law vs pristine: chain away 1 to 2 on 8 case-views: vc20, vc27 and vc32 d/e, vn01 e, and vn39 d. These
    are the two breaks.
  - Fix vs pristine: chain away 0 on all 184 movers, 1069 records toward golden.
  - Positive control (binaries swapped, every twelfth mover): away on 15 of 16. vt11 is neutral, stage 1 on
    both binaries.
- **uhdm-cmp:** 40 line counts change, all falling. The TD one-statement shapes go from 50 to 422 lines down
  to 0, or to 14 to 66 on the shapes with another face.
- **Downstream** (drivers/dscases.py on all 113 dirs, one binary after another): the same verdict on
  pristine, law and fix for every dir. 105 IDENTICAL, 6 EQUIVALENT and 2 DIVERGENT on every binary
  (evidence/downstream_cases.txt).

Movers worth naming:

- vu01_local_shadow: a function-local `localparam int P[2]` beside the interface's `P[3]`. Golden binds the
  INTERFACE parameter's array_typespec (line 3) even under the shadow, and the law does the same: toward
  golden.
- vc12_userfn_op stays STRICT_EQUAL and moves only the stored full name of the cast's alias reference. It sits
  inside a call argument where golden writes an unsupported_typespec, so neither the comparator nor the dump
  reads it.

## Residues (ranked; all wrong on pristine too, chain away 0)

1. **NESTSEL twins not reached.**
   - vn03: an indexed part select in the index, `ea[k[0+:2] + 2'd1]`. Golden names it by the path and spans
     5:22-29.
   - vn19: a 2-D var_select `m[k[0]][1]`. This is the var_select twin the implementer lists for v92_b2_varsel.
   - vn14: a hier_path in the index, `hs[k[0]].i + 1`, at endcol.
   - vn35: a reference in the nested select's own index under a conditional. Golden names `c` through the
     select, `...fld.k.c`, where ours names it `...fld.c`.
   - vn22 e and vn39 e: the class method's elaborated view and the import clone's elaborated view, the
     implementer's residue 3.
   - vn38 d: an import-clone ref_typespec name.
2. **TDBEGIN anchors.**
   - vt16 and vt05: the one statement is a named block or a fork. Golden anchors the wrapper at the whole
     `begin : blk ... end` / `fork ... join`, where the law anchors at the inner statement (`line`).
   - vt22: a package `import` as the second item. TDITEM abstains with `unmatched`.
   - vt11: `this.d = new[3]` as the one statement. TaskFuncEmit's § thisSuperNewAssignNoStmt3 call site 5
     drops the whole body, the new begin included, where golden keeps an empty begin. TaskFuncEmit is the
     sister's ground: REPORT.
3. **CASTALIAS shapes still at stage 1 on every binary.** These are the cast faces of a written `$signed` /
   `signed'`, nested casts, a typedef in the generate block (exit 4), int and alias typedefs, a parameter
   delay, a package-parameter range, a child with overrides (exit 4) and a genvar typedef range: vc04, vc05,
   vc06, vc08, vc09, vc13, vc14, vc15, vc20, vc21, vc27 to vc29, vc31 and vc32.
4. **UIPARAMTS.** vu04 (a struct element) and vu01 stay at stage 1. vu06 and vu09 (instantiated interfaces)
   are unmoved stage-1 shapes.
5. **The implementer's residues stand as written.** These are vh_arrelem, v15, t12, v92_b2_varsel,
   r11v4repro/v6, the r11u109 value cases, c2_idxkind's faces, the class elaborated view, and the
   sister-ground faces (g13, x64_two_dims_positional, e05_untaken_bare_partsel, g1k_hop_userfn,
   a9_class_holder, v97 c3/c9, GC k24).

## Process

- **Order of work.**
  - The pristine and law binaries were built in separate fresh worktrees at 1a9530f6 (/tmp/wt_v11u304pris;
    /tmp/wt_v11u304 with the patch applied) and frozen before any measurement.
  - The refinements were edited only after the law binary was frozen.
  - The fix binary is draft d1, frozen before its census and sweep.
  - The firing census was frozen before the fix sweep.
- **Fresh-apply check.** The source patch (src only) applies clean on a fresh 1a9530f6 worktree
  (/tmp/wt_v11u304chk) and rebuilds to the fix binary's md5.
- **THE VERIFIER'S SLIPS, no effect:**
  - The first away-census run failed on drivers copied without their execute bits and without awayrows.py.
    Fixed and rerun; no number came from the failed run.
  - One wait loop used `pgrep -f` on a pattern naming this pass's census command. The pattern could match the
    waiting shell itself. The loop ended on its file condition, and no process was signalled.
  - A probe byte comparison first set the pristine sweep's databases (built from /tmp/wt_v11u304pris) against
    the law's (built from /tmp/wt_v11u304). Every database differed because the embedded source path
    differs. The pristine probe stage was rerun from the law worktree (/tmp/v11u304_wdQ) before any probe
    mover was counted.
  - A first test edit of the grid driver failed on sed quoting and was redone with Python. Nothing ran on it.
- **Fence.** $FENCED was read fail-closed from tools/probe/r11u107repro/canaudit.sh in every driver. Every
  path list over tools/probe, tests/probe or a sweep workdir was filtered before any file was opened. No
  fenced name was spelled. The fence scan of this directory reads 0.
- **Scope.**
  - No other agent's process was touched.
  - Nothing was written outside /tmp/wt_v11u304*, /tmp/v11u304_* and the session scratch.
  - The main tree was not written.
  - Every sweep exited 1 on the law-index check alone. The base's tests/LAWS.md is itself stale on its commit
    column.
- **Drivers.**
  - Copied from tools/probe/r11u304repro/drivers, with scratch paths renamed to /tmp/v11u304_*.
  - New: grid3.sh, grid3sum.py, grid3attrib.py and bytecmp.sh.
  - No patch file is kept in this directory.
