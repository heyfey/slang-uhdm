# r10earl119 — § `genCaCastFoldDefaultView119` — **SURELOG'S CONTINUOUS-ASSIGN WRITER FOLDS AND `adjustSize`s A BOUND-Lhs GEN-SCOPE CAST IN *EVERY* MODE, BECAUSE `UhdmWriter::writeCont_assign` IS THE INSTANCE-TREE WRITER AND NOT AN `-elabuhdm` PASS; OUR OWN FOLD WAS `UHDM::UhdmAdjuster`'s, WHICH ONLY RUNS UNDER `--elabuhdm`** — the Earlgrey_0_1 **default** head at `padctrl.sv:39:24` CLEARED, and the design's whole cast/fold family CLOSED (1 of 706 cells differing → 0)

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**, **nothing was promoted** and **NO CORPUS ROW
CONVERTED** in either direction — `BuildUVMPkg` (both modes),
`Earlgrey_0_1/testflags` and `Rggen/default` are all quoted below still
`CMP_EQUAL`.  `GOLDEN_DEFER` stayed unset.  The four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own `FENCED=` list,
which `widerun119.sh` reads so the boundary filter cannot drift from the audit.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.
One name collision to keep straight: this pass's subject is an ASSIGNMENT's
right-hand side.  Where that is meant it is spelled `cont_assign::Rhs`.

| | |
|---|---|
| BASE | `f7a77143` |
| pristine binary | md5 `a2733a6622a01308a82a434a9e747d5e`, built from this pass's OWN worktree at a clean `f7a77143` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary (SHIPPED) | md5 `8799d09f4507aa42d3c74bfd630473b2`, frozen `chmod 555`.  **REPRODUCED**: `/tmp/r10earl119.patch` applied to a FRESH `f7a77143` worktree and rebuilt there gives the SAME md5 — the patch IS the artifact every number below was measured on |
| the head | **Earlgrey_0_1/default, 56 cmp lines, ONE head → 833 cmp lines, ONE head, and the head OBJECT IS GONE.**  Before: golden's folded `constant` (`vpiDecompile:63`, `vpiSize:8`, `UINT:63`, `vpiConstType:9`) against our unfolded cast `operation` (`vpiOpType:67`) at `padctrl.sv:39:24` — r10earl118's R0.  After: a DIFFERENT object, `LHS: package top_pkg` / `RHS: <null>`, which the PRISTINE ladder already named at rung 1.  Counts are DEPTH, not distance (RESUME.md §7) |
| production surface | `src/ModuleEmit.cpp` (one new function, `applyCaCastFoldDef119`), `include/UhdmExporter.h` (its declaration), `uhdm_main.cpp` (one gated call).  Nothing existing was edited except the include list and those two insertion points |

---

## 1. THE JUDGE, DECODED FIRST — `own119`, for a **VALUE** head

`own119.cpp` reads the generated Compare orders before naming anything.  The
owner here is a `cont_assign`, whose generated order
(`~/git-repos/UHDM/build/generated/src/cont_assign.cpp:99-127`) is

```
VpiNetDeclAssign, VpiStrength0, VpiStrength1, Delay, ==> Rhs <==, Lhs, Cont_assign_bits
```

**the Rhs is read BEFORE the Lhs** — which is why an Rhs difference hides
whatever the target reference is doing, and why this head sits at the same
statement family r10earl118 just finished working on without being that law.

`OWNER_BEFORE.r10earl119.txt`, on the pristine databases:

```
HEAD LHS(golden) = constant dec='63' size=8 ts=<null> val='UINT:63' ctype=9  @ 0:0-0:0
HEAD RHS(ours)   = operation dec='' size=0 ts=ref_typespec->int_typespec optype=67
                   operand0=constant  @ 39:24-39:38
BOTH SIDES PRESENT: yes   (a VALUE head, not a null one — the SINGULAR
                           SafeCompare overload would have left one side unset)

== OWNER cont_assign  golden=padctrl.sv 39:12-39:38  ours= 39:12-39:38
   -- cont_assign::Compare FIELD ORDER (fresh context each) --
      Rhs   golden=constant  ours=operation  -> -32   <== FAILS (before Lhs)
      Lhs   golden=ref_obj   ours=ref_obj    ->  0
         golden Lhs.Actual_group: logic_var 'warl_mask' @padctrl.sv 36:22-36:31
         ours   Lhs.Actual_group: logic_var 'warl_mask' @ 36:22-36:31
```

Three measurements, none of them inferred:

* **the failing field is `cont_assign::Rhs`**, re-run with a FRESH context;
* **the `Lhs` compares EQUAL** — both sides bind the target to the same
  `logic_var`.  So this is NOT r10earl118's family (which is about a target
  that must be UNBOUND), even though it is the same statement kind: golden's
  `bindVariable` SUCCEEDS here, and that success is exactly what makes it fold;
* **golden's folded constant is PARENTLESS and LOCATION-LESS** — the owner
  could not be reached by walking up from the head at all, and had to be found
  by scope-fullname + span.  That is Surelog's own doing: the bound-Lhs leg of
  `writeCont_assign` does a bare `assign->Rhs(rhstmp)` (UhdmWriter.cpp:2159) and
  never stamps a parent, and `ExprEval`'s cast mint never carried a location.

**THE SIBLING CENSUS, whole design, both sides** (`own119`'s second half — every
gen-scope `cont_assign` whose Rhs is a cast or a folded constant, compared on a
COMPARE-VISIBLE payload only, because our objects carry an EMPTY `VpiFile` and a
span in the key prints every cell as a difference):

```
BEFORE:  golden 706 cells, ours 706 cells — same=705 diff=1 only-golden=0 only-ours=0
   DIFF work@top_earlgrey.u_padctrl.gen_generic|warl_mask|39:12
        golden constant dec='63' size=8 val='UINT:63' ctype=9
        ours   operation optype=67 operand0=constant dec='6'h3F' size=6 val='HEX:3F' ctype=5
AFTER:   golden 706, ours 706 — same=706 diff=0 only-golden=0 only-ours=0
```

So the head was the design's LAST differing cell of its own family, and the
family is CLOSED in this row.

**THE LADDER** (mask-and-rerun around the official `design::Compare`; counts are
LOWER BOUNDS, masks cascade — RESUME.md §9).  On the pristine databases rung 0
is the head and **rung 1 is `LHS: package top_pkg` / `RHS: <null>`** — i.e. the
pass PREDICTED its own next head before it was written, and that is exactly what
the patched binary now shows.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

`UhdmWriter::writeCont_assign` (`src/DesignCompile/UhdmWriter.cpp:2090`) is
reached from **`writeElabGenScope` (:2367)**, **`writeElabModule` (:4107)** and
**`writeElabInterface` (:4258)** — the INSTANCE-tree writers.  Nothing on that
path is conditioned on `-elabuhdm`; `-elabuhdm` adds `UHDM::ElaboratorContext` +
`UhdmAdjuster` AFTER the writer has already run.  Its bound-Lhs leg (:2121-2172):

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {
    if (rhs->UhdmType() == uhdmoperation) {
      … clone_tree(assign) …
      any* rhstmp = m_helper.reduceExpr((expr*)rhs, invalidValue, …);
      if (expr* exp = any_cast<expr*>(var))            // the TARGET's
        if (const ref_typespec* rt = exp->Typespec())  //   typespec
          if (const typespec* t = rt->Actual_typespec()) tps = t;
      if (!invalidValue && rhstmp)
        if (rhstmp->UhdmType() == uhdmconstant)
          rhstmp = m_helper.adjustSize(tps, …, (constant*)rhstmp, /*uniquify*/true);
      assign->Rhs((expr*)rhstmp);
```

* `CompileHelper::reduceExpr` (`src/DesignCompile/CompileExpression.cpp:823`) IS
  `UHDM::ExprEval` wearing Surelog's name-lookup functors — the same evaluator
  `UhdmAdjuster::updateParentWithReducedExpression`
  (`UHDM/templates/UhdmAdjuster.cpp:331-345`) runs for us in the other view.
* `CompileHelper::adjustSize`'s `vpiUIntConst` arm
  (`CompileHelper.cpp:3990-4002`) masks the value to the TARGET's width, writes
  the DECIMAL spelling into `vpiDecompile` and sets `VpiSize(size)`.
* When the bind FAILS the assign takes a DIFFERENT clone leg (:2218-2242, the
  cast's own `Typespec()` and `flattenPatternAssignments`), `simplified`
  becomes true, and the tail's `reduceExpr` (:2246-2280) is never reached — the
  Rhs stays the OPERATION.

**MEASURED, not deduced.**  r10earl106's four arms were built TWICE by the real
Surelog — `-parse` alone and `-parse -elabuhdm` — and the ELABORATED
(`uhdmtopModules`) section of the two golden databases was censused
(`cen119`):

| arm | golden DEFAULT vs golden ELAB, cells that differ |
|---|---|
| `g1_home106` | 4: `loc_c` (gen-local target), `m_sel[3]`, `m_sel[7:4]`, the interface's `iv` |
| `g2_form106` | 0 |
| `g3_val106` | 0 |
| `g4_fence106` | 1: `anc` (an ANCESTOR gen scope's local) |

Every differing cell is a **bind-FAILS** cell, and in each the DEFAULT view has
the operation and the ELAB view has golden's own adjuster-folded 64-bit
constant.  **On every bind-SUCCEEDS cell the two golden views are IDENTICAL** —
the writer's answer, mode-independent, exactly as the source says.

Our side: `uhdm_main.cpp` runs the elaborator, the adjuster and
`applyCaCastAdjust106` only under `--elabuhdm`, so in the default view every one
of those cells keeps the `vpiCastOp` operation.  The head is one of them.

---

## 3. WHAT WAS BUILT, AND THE FENCES THAT ARE PART OF IT

`UhdmExporter::applyCaCastFoldDef119` (`src/ModuleEmit.cpp`, beside
`applyCaCastAdjust106`), called from `uhdm_main.cpp` under `if (elabUhdm !=
true)` — the two consumers are **MUTUALLY EXCLUSIVE**, which is why the
elaborated view cannot move by a byte.

It reuses § `genCaCastFoldAdjustSize106`'s **record set unchanged**: one entry
per elaborated gen-scope `cont_assign` with a WRITTEN cast Rhs whose Lhs
`caLhsAdjustBind106` binds.  That predicate is r10earl106's + r10v106's
gate-verified model of `bindVariable` + `adjustSize` (module-body declaration
only, no implicit net, no bare `var`, no interface home, `real` 32 and no other
floating kind, no `time`), and the key is theirs too (gen-scope FULLNAME +
cont_assign SPAN + Lhs NAME — the comma-list discriminator r10v106 added).

On each such cell it runs the fold Surelog runs and then the re-encode
r10earl106 already decoded, with FOUR conditions checked BEFORE `ExprEval` is
ever called:

1. the Rhs is still an `operation` of type `vpiCastOp`;
2. it has EXACTLY ONE operand and that operand is already a `constant`;
3. the cast typespec is one `ExprEval`'s `vpiCastOp` arm
   (`UHDM/templates/ExprEval.cpp:4074-4204`) has a branch for — `int`,
   `long_int`, `bit`, `short_int`, `integer`, `enum`;
4. `ExprEval::get_value` on that operand is VALID.

Only then does `reduceExpr` run, and only a `vpiUIntConst` result is re-encoded
(`adjustSize`'s other arms are different arithmetic — r10earl106's fence, kept).

**Why the pre-checks are load-bearing and not decoration.**  `reduceExpr` MINTS
(`s.MakeConstant()`) and can MUTATE an operand (`resize`, ExprEval.cpp:1627),
and a mint on a cell we then decline would leave arena litter.  With the checks
in front, a cell this law cannot fold is never offered to the evaluator.  The
proof is arm `a2_fence119`, which is ALL fences and residues: **its default-view
database is byte-identical between the two binaries** (dump md5 equal, banner
line excluded).

**Why the evaluator and not arithmetic of our own.**  Three grid cells settle
it, and no hand-rolled fold would have got any of them right:

| written | golden (default view) | why |
|---|---|---|
| `assign d_scal = 64'(64'hFFFF_FFFF_FFFF_FFFF);` onto `logic [7:0]` | `UINT:0` size 8 | `ExprEval`'s `integer_typespec` arm computes `mask = (1ULL << 64) - 1`, which is **0**, so the value masks to nothing — arithmetic no independent implementation would reproduce |
| `assign v_xz = 8'(6'b1111xx);` | `UINT:15` size 8 | `get_value` parses the binary digits and stops at the first `x`: `1111` = 15 |
| `assign v_zz = 8'(6'bzzzzzz);` | the OPERATION, unfolded | the same parse finds no digits, `invalidValue`, no fold — and we keep the operation too |

---

## 4. THE GRID — 6 + 8 ARMS × BOTH VIEWS × GOLDEN + BOTH BINARIES, EVERY CELL SCORED

`grid119.sh` builds every arm with the REAL Surelog and both frozen binaries in
both views and records every rc (`GRID_dbrc.r10earl119.txt`: all zero);
`gridscore119.sh` scores each gen-scope cell golden-vs-pristine-vs-patched on
the COMPARE-VISIBLE payload.  `GRID.r10earl119.txt` (this pass's two arms +
r10earl106's four) and `GRID_earlierarms.r10earl119.txt` (r10earl106's `h1` and
r10v106's seven `va*` arms):

| arm | DEFAULT view | ELAB view |
|---|---|---|
| `a1_def119` | SAME 7, **TO-GOLDEN 10**, STILL-WRONG 2 | SAME 18, STILL-WRONG 1 |
| `a2_fence119` | SAME 10, STILL-WRONG 9, **TO-GOLDEN 0** | SAME 14, STILL-WRONG 5 |
| `g1_home106` | SAME 10, **TO-GOLDEN 7** | SAME 17 |
| `g2_form106` | SAME 4, **TO-GOLDEN 16**, STILL-WRONG 2 | SAME 22 |
| `g3_val106` | SAME 5, **TO-GOLDEN 11**, STILL-WRONG 14 | SAME 21, STILL-WRONG 9 |
| `g4_fence106` | SAME 5, **TO-GOLDEN 2**, STILL-WRONG 2 | SAME 7, STILL-WRONG 2 |
| `h1_head106` | SAME 6, **TO-GOLDEN 1** | SAME 7 |
| `va1_word106` | SAME 2, **TO-GOLDEN 10** | SAME 12 |
| `va2_lhs106` | **TO-GOLDEN 15**, STILL-WRONG 1 | SAME 16 |
| `va3_span106` | SAME 2, **TO-GOLDEN 10** | SAME 12 |
| `va4_cast106` | SAME 3, **TO-GOLDEN 4**, STILL-WRONG 11 | SAME 13, STILL-WRONG 5 |
| `va5_scope106` | SAME 8, **TO-GOLDEN 5** | SAME 13 |
| `va6_neg106` | SAME 6, **TO-GOLDEN 3**, STILL-WRONG 9 | SAME 15, STILL-WRONG 3 |
| `va7_mix106` | SAME 4, **TO-GOLDEN 4** | SAME 8 |
| **TOTAL** | **TO-GOLDEN 98 · AWAY-GOLDEN 0 · MOVED-WRONG 0 · NOGOLD_MOVED 0** | **AWAY-GOLDEN 0 · MOVED-WRONG 0 — every ELAB database byte-identical** |

`a1_def119` is the axis arm this pass adds, and every row of it is a
discriminator r10earl106's arms do not carry:

| row | shape | golden (default) | patched |
|---|---|---|---|
| `d_a` | the head shape | `UINT:63` / 8 | same → TO-GOLDEN |
| `d_b`, `d_c` | a COMMA LIST in one gen scope, targets 8 and 4 wide | `UINT:63`/8 and `UINT:15`/4 | both right — the r10v106 name-in-key holds in this view too |
| `n_w` | a declared NET target | `UINT:63` / 8 | TO-GOLDEN |
| `imp_n` | an IMPLICIT net target | the OPERATION | untouched (SAME_AGREE) |
| `loc_e` | a GEN-LOCAL target | the OPERATION | untouched |
| `d_ns` | the NAMESAKE (module body AND gen-local) | `UINT:63`/8 (golden binds the MODULE-BODY namesake) | **STILL-WRONG — residue R3** |
| `d_loop` | three unrollings of ONE written span onto a net | 3× `UINT:63`/8 | all three right |
| `d_deep` | generate DEPTH 3 | `UINT:63` / 8 | TO-GOLDEN |
| `d_time` | a `time` target | `UINT:63` / **64, no decompile** | **STILL-WRONG — residue R2** |
| `d_ub` | `W8'('1)` — `ExprEval::resize` mutates the operand | `UINT:1` / 8 | TO-GOLDEN |
| `d_bit` | a 1-bit target: the mask must bite | `UINT:1` / 1 | TO-GOLDEN |
| `d_scal` | `64'(64'hFFFF_FFFF_FFFF_FFFF)` onto 8 bits | `UINT:0` / 8 | TO-GOLDEN |
| `ch_v` | a CHILD instance's gen scope | `UINT:63` / 8 | TO-GOLDEN |
| `if_v` | an INTERFACE's gen scope | the OPERATION | untouched |

and `a2_fence119` is the arm that must move NOTHING — it does not, byte for
byte.  Its ten SAME_AGREE rows are `byte'(…)`, `logic'(…)`, `8'(6'bzzzzzz)`, a
bit-select target, a part-select target, a PROCEDURAL cast in a gen scope, a
MODULE-BODY cont_assign, and `'1`; its nine STILL-WRONG rows are the two named
residues below.

---

## 5. THE CORPUS — CENSUS, PREDICTION, AND THE ONE BYTE MOVER

`cen119` walks `AllModules`/`AllInterfaces` (DEF) and `TopModules` (ELAB) —
never `Serializer::AllObjects`, whose weaklyReferenced tail is unreachable to
the judge.  Key = `home | scope-kind | gen-depth | lhs-kind | lhs-name |
ca-span`, with the DEF/ELAB view deliberately OUT of the key (the two producers
label it differently) and on a diagnostic `VIEWCELL` row instead.  Payload =
the Rhs shape with its COMPARE-VISIBLE constant fields.

**CALIBRATION FIRST** (`score119.py` refuses to score otherwise): the GOLDEN
halves of the two sweeps are IDENTICAL — surelog 101 311 keys / 462 550 cells,
uhdm2rtlil 3 626 keys / 11 360 cells.

**THE PREDICTION, made from the PRISTINE databases alone** (`predict119.py`,
`PREDICT_sl.txt` / `PREDICT_u2r.txt`), before the patched sweep existed:

```
surelog     PREDICT-MOVE default Earlgrey_0_1  1 cells      rows=1 cells=1
            PREDICT-AWAY  rows=0
            PREDICT-DECLINE rows=2 cells=260
uhdm2rtlil  PREDICT-MOVE  rows=0 cells=0
            PREDICT-AWAY  rows=0
            PREDICT-DECLINE rows=2 cells=2
```

In the WHOLE surelog corpus only Earlgrey_0_1 holds a gen-scope `ref_obj`-Lhs
cell whose Rhs is still `op67`: 6 keys in default (1 with a constant operand — the
head — 4 with an operation operand, 1 with a `ref_obj` operand) and 5 in
testflags.  Golden holds 612 folded gen-scope cells there, so the family is
large and we already agree on all but this one.

**THE RESULT** (`CENSUS_sl.txt` / `CENSUS_u2r.txt`):

```
surelog     FX TO-GOLDEN    1 keys     1 cells
            FX AWAY-GOLDEN  0 · FX MOVED-WRONG 0 · REST NOGOLD_MOVED 0
            FX SAME_AGREE 665 keys · FX STILL-WRONG 2561 keys (residue R4)
            REST SAME_AGREE 17604 keys · REST STILL-WRONG 80480 keys (untouched)
            MOVER ROWS: default Earlgrey_0_1 {'FX TO-GOLDEN': 1}
            the moved cell: work@padctrl|gen_scope|g1|ref_obj|warl_mask|39:12-39:38
                golden  = const|9|8|63|UINT:63
                pristine= op67
                patched = const|9|8|63|UINT:63
uhdm2rtlil  DETAIL_TOTAL 0 — not one cell moved, in either mode
```

**THE BYTE MOVER**: `byteverify.sh SELFCHECK=1` reports **1 / 956** on the
surelog corpus (`./default/Earlgrey_0_1-71da2fd7/slang.uhdm`) and **0 / 1358**
on uhdm2rtlil — exactly the predicted set, by name.  `attrib119.sh`'s
path-normalised, ORDER-BLIND, SECTIONED diff attributes it line by line
(`ATTRIB_Earlgrey_default.diff`): section 0 (the DEF listing) carries only the
dump's own banner line; section 10 loses one `operation` with its
`ref_typespec (work@top_earlgrey.u_padctrl.gen_generic)`, its
`int_typespec (AttrDw)` and its `6'h3F` operand, and gains one `constant` with
`vpiDecompile`/`vpiSize`/`vpiConstType`/`UINT`.  One cell, nothing else.

---

## 6. THE GATES — ALL GREEN, AND NO ROW CONVERTED

Full transcript in `GATES.r10earl119.txt`.  In one line: goldens 23/0 on both
binaries and 0/23 on `/bin/false`; uhdm2rtlil 679/50/2 in both modes on both
binaries with `ct8rows` PASS three ways and 0/1358 byte movers; surelog 1588
rows with `ct8rows` pristine-vs-patched PASS (0 differing rows, status AND dump)
and 1/956 byte movers; canaries 51+8 ok, `ctcan2` PASS twice, `canaudit`
audited=29 UNCOVERED=0 FENCE-BREACH=0; SVSwitch `4842211c4030` and YosysVerx
`6ccda350c24a` pins hold; InterfaceModPort / BlackParrotComplex / YosysOldOr
byte-identical.

**The one row-side that differs from the COMMITTED baseline, quoted in full and
NOT a conversion:**

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ      (results/golden_surelog.csv)
> Earlgrey_0_1,testflags,CMP_EQUAL,,,            (both of THIS pass's sweeps)
```

The STATUS is `CMP_EQUAL` on both sides; only the dump column empties, and it
empties in the PRISTINE sweep too (`ct8rows` pristine-vs-patched is PASS on that
row).  It is a `uhdm-dump` TIMEOUT under four concurrent sweeps, and the dumps
prove it: the testflags database's dump sha256 is
`7590acc9…517a5f` for BOTH binaries against golden's cached `d6624210…6090a`,
so the verdict is `differ` on both sides and the two databases are byte-identical
to each other.  Nothing was promoted and `results/*.csv` was not edited.

---

## 7. THE WIDE BOUNDARY — EVERY COMMITTED ARM, AND A FALSE MOVER CONVICTED BY A THIRD BINARY

`widerun119.sh` stages a COPY of `tools/probe`, lists every `.sv`/`.v` at ANY
depth, filters the fenced names out of the list BEFORE a child runs, reads the
list on fd 3 with children `</dev/null`, and asserts PROCESSED == LISTED.

```
LISTED=5223  FENCED_REMOVED=0  (of 5223 found)
PROCESSED=5223 identical=9993 DIFFERING=19 no_output=434
PROCESSED==LISTED (5223)
rc by side:  A/0 9615  A/139 16  A/3 418  A/4 397
             B/0 9615  B/139 16  B/3 418  B/4 397     <-- SYMMETRIC
```

The rc histogram is identical on both sides: no new rejection, no new signal.
Of the 19 differing arm×view cells:

* **13 are this law's own family in the DEFAULT view** — r10earl106's
  `g1`/`g2`/`g3`/`g4`/`h1`, r10v106's seven `va*` arms, and this pass's
  `a1_def119`.  Every one was re-measured AGAINST GOLDEN in §4: **TO-GOLDEN 98,
  AWAY-GOLDEN 0, MOVED-WRONG 0**.  (`a2_fence119` is absent from the list: the
  all-fences arm does not move.)
* **6 are three files moving in BOTH views** — `r10buvm22repro/g22.sv`,
  `r10uvm154repro/l154_noenum.sv`, `r10uvm185repro/grid185/g185_e_kinds.sv`.
  An ELAB-view move cannot be this law (the call is gated on `elabUhdm !=
  true`), and it is not: the diff is ONE constant per file, always
  `22650617 → 22654713`, **delta 4096 = one page**, on the RIGHT RANGE of a
  DYNAMIC-ARRAY dimension (`typedef C22 kd_cls_t[];`) whose bound our emitter
  fills from a static address — a value that is golden's on neither binary.
  **CONVICTED** by a THIRD binary built from this tree with the call site behind
  an environment variable, so the law is compiled in but NEVER RUNS: it moves
  the cell exactly as the patched binary does (for `g185` the whole dump md5 is
  identical to the patched one).  RESUME.md §9's "static-address false mover:
  named arms move when the binary grows a page", with its own tell — zero
  census movement — also present.  `FALSEMOVER.r10earl119.txt` has the table.
  The call site was then restored and the tree rebuilt; the rebuild reproduces
  the shipped binary's md5 byte for byte.

---

## 8. RESIDUES

* **R0 — THE NEXT HEAD, named and measured.**  `Earlgrey_0_1/default`, now 833
  cmp lines / 1 head: `LHS: package top_pkg` (`top_pkg.sv:6:1`) against
  `RHS: <null>`.  It is PRE-EXISTING and merely unmasked — the PRISTINE
  ladder named it at rung 1 (`OWNER_BEFORE.r10earl119.txt`).  `r0next119.cpp`
  takes the ambiguity out of the `<null>`: `design::Compare`
  (`design.cpp:295-302`) reads `Include_file_infos, AllPackages, TopPackages,
  AllClasses, …`; **both `AllPackages` and `TopPackages` are 40 entries on both
  sides with NO null entries and identical pairing**, and the isolated
  `top_pkg` pair `Compare`s to **0** with every container equal
  (`Parameters` 11/11, `Param_assigns` 11/11, the rest null on both sides).  So
  the failing edge is a **SINGULAR relation whose golden value IS that package
  and whose value on our side is null** — a pointer TO the package (an
  `Instance`-style or `Actual_group`-style edge reached after the memoised walk
  has already visited it), not anything inside it.  The next pass's first job
  is to name that owner with the owner-finder.  `HEAD_AFTER_Earlgrey_default.cmp`
  holds the head.
* **R1 — THE NON-CONSTANT OPERAND LEG, measured and NOT taken.**  Golden folds a
  gen-scope cast whose operand is a concat, a replication, a binary op, a
  ternary, a system call, a nested cast or a unary minus (`8'(-1)`); this law
  declines them all, because folding them needs `reduceExpr` to run on the
  OPERAND first, which mints and mutates before the outcome is known.  Scored
  as STILL-WRONG, never as MOVED-WRONG: arm `a2_fence119` rows `f_cat`, `f_rep`,
  `f_bop`, `f_ter`, `f_sysc`, `f_nest`, `g3_val106`'s `v_cat`/`v_rep`/`v_bop`/
  `v_ter`/`v_sys`/`v_nest`/`v_catcast`, `g2_form106`'s `tw1`/`tw2`, `va6_neg106`'s
  six rows.  Corpus population: `PREDICT-DECLINE` 260 cells in surelog (all
  Earlgrey), 2 cells in uhdm2rtlil.  A law of its own, with its own grid and its
  own answer to the mint-before-verdict problem.
* **R2 — THE `time` TARGET.**  Golden folds `assign d_time = W8'(6'h3F);` onto a
  `time` variable to `UINT:63` at size **64 with an EMPTY decompile** — i.e.
  `bindVariable` FINDS the `time_var` and `adjustSize` then does nothing,
  because Surelog's `time_typespec` gives it no size to write.  r10v106
  deliberately excluded `time` from `caLhsAdjustBind106` (in the ELAB view the
  adjuster's own constant is already right and writing a decimal decompile there
  is a judge-visible regression), so no record is made and this view folds
  nothing.  The default-view answer needs a "fold but do NOT adjust" record,
  which would change r10earl106's predicate and put its landed measurements at
  risk for one arm cell and no corpus population.  Arms `a1_def119` `d_time`,
  `va2_lhs106` `v_time`.
* **R3 — THE NAMESAKE SHADOW, a hole in the shared bind model.**  `logic [7:0]
  d_ns;` in the module body AND `logic [3:0] d_ns;` inside the gen scope, with
  `assign d_ns = W8'(6'h3F);` in that scope: golden FOLDS with the MODULE-BODY
  target's 8-bit width, because `bindVariable`'s scope walk
  (`CompileStmt.cpp:3089-3151`) knows nothing about `gen_scope` and finds the
  namesake.  slang's symbol is the gen-local, so `caLhsAdjustBind106` returns
  false and no record is made.  Pristine and patched are the same wrong answer
  (STILL-WRONG, arm `a1_def119` row `d_ns`).  This is the SAME fact r10earl118's
  fence decoded from the other side (there the namesake keeps golden's target
  BOUND); the two passes now have one measurement each of it, and a future law
  should fix the shared predicate once.
* **R4 — the 2561 FX `STILL-WRONG` keys of the surelog census** are not this
  law's: they are dominated by NON-cast Rhs shapes golden folds in encodings
  that are different arithmetic (`n_lit` keeps `6'h3F`/HEX, `n_cat` stays
  BINARY, `n_ter` is a `vpiIntConst`), each owned by another law
  (§ `genvarWholeCaRhsFold68`, § `genCaReplWholeFold78`,
  § `genCaEnumWholeRhsFold25`, …).  Named here so the number is not mistaken for
  this law's residue.
* **R5 — r10earl106/110–118's arms and fences are untouched in the ELAB view**:
  every arm's elaborated database is byte-identical between the two binaries,
  and the corpus census's REST family shows AWAY-GOLDEN 0 / MOVED-WRONG 0 /
  NOGOLD_MOVED 0 on both corpora.

---

## 9. FILES

| file | what it is |
|---|---|
| `own119.cpp` | THE JUDGE, decoded: the VALUE-head owner finder — the failing field re-run in `cont_assign::Compare`'s generated order with a fresh context, the golden owner found by scope-fullname + span (golden's folded constant is PARENTLESS), the whole-design sibling census of gen-scope cast/fold cells on a compare-visible payload, and a mask-and-rerun ladder |
| `OWNER_BEFORE.r10earl119.txt` / `OWNER_AFTER.r10earl119.txt` | its output on the pristine and patched databases (706 cells: diff 1 → diff 0) |
| `r0next119.cpp` / `R0_NEXT.r10earl119.txt` | R0's decode: the package vectors scanned for null entries and pairing, and the `top_pkg` pair bisected container by container |
| `cen119.cpp` | the census: every `cont_assign`'s Rhs shape with its compare-visible constant fields, keyed home/scope-kind/gen-depth/lhs-kind/lhs-name/span, DEF/ELAB out of the key, walking the instance trees and NOT the arena tail; diagnostic `VIEWCELL` (view) and `LOCCELL` (location, operand kind, cast typespec kind) rows |
| `censweep119.sh` | runs it over a whole `verify_golden.py` workdir, golden path from each test's OWN `cmds.txt`, every rc logged |
| `score119.py` | the three-way multiset join; asserts the two sweeps' golden halves identical FIRST; TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / NOGOLD, movers as ROWS |
| `predict119.py` | the mover set predicted BY NAME from the PRISTINE census alone, using the reachability conditions the code checks |
| `CENSUS_sl.txt` / `CENSUS_u2r.txt` | the corpus three-way scores, calibration line first |
| `PREDICT_sl.txt` / `PREDICT_u2r.txt` | the predictions, made from the pristine databases |
| `grid119.sh` / `gridscore119.sh` | the arm grid (every arm × both views × golden + both binaries, every rc recorded) and its scorer |
| `a1_def119.sv` | the default-view axes r10earl106's arms do not carry: the comma list, a net target, an implicit net, a namesake shadow, `time`, `'1`, a 1-bit target, depth 3, three loop unrollings, a child instance, an interface |
| `a2_fence119.sv` | THE FENCE ARM: the casts with no `ExprEval` branch, the unreadable operand, the non-constant operands, the non-cast Rhs shapes, select targets, a procedural cast, a module-body cont_assign |
| `GRID.r10earl119.txt` / `GRID_earlierarms.r10earl119.txt` / `GRID_rc.r10earl119.txt` / `GRID_dbrc.r10earl119.txt` | the scored grids and their rc records |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the official `uhdm-cmp` head of Earlgrey_0_1 in both modes, before and after |
| `attrib119.sh` / `ATTRIB_Earlgrey_default.diff` | the sectioned, path-normalised, ORDER-BLIND whole-dump attribution of the single byte mover |
| `wide119.sh` / `widerun119.sh` / `BOUNDARY_*.txt` | the wide boundary over every committed arm, both views, with the fence filter, the rc histogram by side, and the differing list |
| `FALSEMOVER.r10earl119.txt` | the third-binary conviction of the three page-shift arms |
| `GATES.r10earl119.txt` | the five gates, every command and every number |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the gate scripts, carried so this directory reproduces the battery on its own |
