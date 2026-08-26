# r10earl95 — § genCaParamFoldOneHopPool95

**The parameter pool an elaborated gen-scope cont-assign folds from is ONE
EMITTED LEVEL UP, and one only.**

BASE `d7c6e81`, branch `auto5h`.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; every
instrument in this directory is MEASUREMENT ONLY.

---

## 1. The head this pass took

`Earlgrey_0_1`, **both modes**, 46 / 50 cmp lines, one head each, re-measured on
this pass's own pristine build `a7c25e51887a` (`HEAD_BEFORE_*.cmp`):

```
prim_lfsr.sv:308   assign coeffs = GAL_XOR_COEFFS[LfsrDw-GAL_XOR_LUT_OFF][LfsrDw-1:0];
the `LfsrDw` at 308:38-308:44, parent operation 308:38-308:60 (vpiSubOp),
grandparent var_select GAL_XOR_COEFFS 308:23-308:73, in
work@top_earlgrey.u_aes.aes_prng.aes_prng_lfsr.gen_gal_xor.gen_lut

  golden  default    ref_obj LfsrDw   Actual_group <null>
          testflags  ref_obj LfsrDw   Actual_group -> parameter LfsrDw 33:32-33:38
                                      of THAT INSTANCE
  ours    both       constant UINT:64 vpiSize 32 vpiConstType 9,
                     ref_typespec -> int_typespec 33:13-33:25
```

Two non-null objects of DIFFERENT `UhdmType`, so the head is the `VpiType` line
in `BaseClass::Compare` before any per-kind field is read.

## 2. The decoded model, and the candidate r10earl94 left behind is REFUTED

`r10earl94`'s `PREDICT_R0.txt` fact (4) proposed that `GAL_XOR_COEFFS` — a
`localparam logic [63:0] [61]` — is un-evaluable, so Surelog's `reduceExpr`
bails on the SELECT and the whole index tree survives.  **That is not the
mechanism.**  `g4_kind95.sv` reads ONE module parameter from the SAME position
over SEVEN base kinds (localparam unpacked array of wide values, localparam
unpacked array of int, packed parameter vector, net, variable, PORT, array of a
struct), at generate depth 1 and again at depth 2.  Golden folds **every** kind
at depth 1 and keeps the `ref_obj` for **every** kind at depth 2.  The selected
object never enters the decision; the generate NESTING does.

The mechanism is the one this codebase already decoded at
`§ genLpOneHopProcBoundOp58` (`src/ExprEmit.cpp`), and this pass supplies its
CONT-ASSIGN half:

* `CompileHelper::compileContinuousAssignment` (`CompileHelper.cpp:2470/2498`)
  compiles BOTH sides at **`Reduce::No`** — always.  At `Reduce::No` the only
  substitution `CompileExpression`'s identifier arm can still make is the one
  guarded by `param_ass->Rhs()->UhdmType() == uhdmconstant` over
  `instance->getNetlist()->param_assigns()` (`CompileExpression.cpp:2862-2911`).
* `DesignElaboration::elaborateInstance_` compiles a generate block's
  `ModuleDefinition` with `m_instance = parent`, and `elab_parameters_` fills
  that netlist's `param_assigns` from the PARENT's OWN parameters, nothing
  inherited.
* So the pool visible inside a generate block is exactly its parent scope's own
  parameters.  **Distance 0 (the block's own localparams) is invisible;
  distance 1 is visible; distance 2 and beyond are invisible.**

Two consequences this pass also measured and did not have to assume:

* the ELABORATED copy's `Actual_group` costs us nothing.  Under `--elabuhdm`
  `uhdm_main.cpp` runs UHDM's own `ElaboratorListener` and `UhdmAdjuster`,
  exactly as Surelog does (the `V-FIX v61` note in `include/UhdmExporter.h`
  records the same reasoning for port `High_conn`), so emitting the bare
  `ref_obj` reproduces golden's testflags copy — `Actual_group -> parameter` —
  **by construction**.  Measured: `g3_pool95` rows 43/44/45/54 come out
  `{ref null ×3, ref->parameter ×3}` on both sides, cell for cell.
* golden's part-select BOUND in the elaborated copy is a REDUCED CONSTANT, not
  the operation: `UhdmAdjuster::leaveOperation` →
  `updateParentWithReducedExpression` installs a constant into a
  `part_select`/`bit_select`/`indexed_part_select`/`operation`/`cont_assign`
  parent but **not** into a `var_select` — which is why golden keeps the
  `ref_obj` under the var_select index at `308:38` and holds a constant at the
  part-select bound `308:62`.  Our binary runs the same adjuster and lands the
  same way (census key `part_select|308:62-308:72|lr` is `constant[INT:63]` on
  BOTH sides in testflags, before and after).

## 3. The law

`src/ExprEmit.cpp`, `genCaOneHopPool95` + `genCaPoolScope95For`, consumed at the
TWO fold arms of the elaborated gen-scope cont-assign window (`SITE 1` the
select bound, `SITE 2` every plain operand — the `var_select` INDEX included,
because `inPsBound` is set inside part-select bound emission only).  It is a
**REFUSAL ONLY**: it can never fold where the pristine binary did not.

> In an ELABORATED generate-scope `cont_assign`, a parameter's value is
> substituted only when the parameter is declared in the generate block's
> IMMEDIATE PARENT SCOPE — the enclosing module instance body for a top-level
> block, the enclosing GENERATE SCOPE for a nested one.  The block's own
> declarations and every scope two or more levels up keep their `ref_obj`.
> A parameter outside the instance/generate chain (a PACKAGE parameter) is a
> different Surelog arm and is left alone: golden folds it at every depth.

**THE HOP IS COUNTED IN THE EMITTED TREE, NOT IN SLANG'S SCOPE TREE**, and that
clause is not decoration — it is a regression this pass made and fixed before
landing.  `pushGenBlk9` splices generate levels out of the model
(`§ genElseArmCollapse48`: an ELSE arm whose first item is a named if-generate;
`genHoists9`), and Surelog's elaborator drops exactly the same levels.
`genEmitStack95` is pushed by `emitBlock` and by nothing else, so it holds only
the blocks that actually became a `gen_scope`.

**AND THE STACK CROSSES INSTANCE BOUNDARIES WHILE THE HOP DOES NOT** — the
second regression, and the one a canary caught.  A module instantiated inside a
generate scope is emitted with that scope's frames still on the stack, so
`genCaPoolScope95For` accepts the entry one level up only when it belongs to the
SAME `InstanceBody`; otherwise this block is the outermost emitted generate
level of its own module and the pool is that module's body.

## 4. The fences, each MEASURED on a purpose-built golden

`ARMS.r10earl95.txt` carries every cell.  Five arms, both views, three
instantiations of one parameterized module (W = 5/6/8, or 4/6/8) per arm, LHS
always golden.

FOLDS in golden — the law abstains (distance 1, or outside the chain):

| arm | row | what is read |
|---|---|---|
| g3 `d1` | 26/27/30/31/32/33 | module PORT param, module localparam, in a part-select bound, a var_select index, a replication count, a plain operand, an ips base |
| g3 `d2` | 41 `D1`, 48 ips base | the PARENT gen scope's localparam, two levels down |
| g3 `d3` | 53 `D2` | the PARENT gen scope's localparam again, three levels down |
| g3 `d1`/`d2` | 28/40 `p95::PKGW` | a PACKAGE parameter, at EVERY depth |
| g3 `f1`/`f2` | 62, 66 | a for-generate body and its nested gen-if |
| g4 `h1` | 26-32 | ALL SEVEN base kinds at depth 1 |
| g5 `c_in` | 28/29 | the COLLAPSED else arm — two blocks in slang, ONE `gen_scope` in golden |
| g5 `f_top` | 34 | the flat control |

KEEPS the `ref_obj` in golden — the law fences:

* distance 0, the block's own localparam: g3 rows 29 (`D1` at depth 1, nested in
  a bound OPERATION — a cell `§ genScopeOwnParamNoSelFold56`'s DIRECT-bound
  fence does not reach), 42 (`D2`), 63 (a for body's own `F1`);
* distance ≥ 2, a module parameter or localparam: g3 rows 38/39/43/44/45 (depth
  2) and 51/54 (depth 3), g2 rows 26/27/34, g4 rows 37-40 and 42 (every base
  kind), g5 rows 22/23 and 36;
* distance ≥ 2, a GRANDPARENT gen scope's localparam: g3 row 52 (`D1` read at
  depth 3);
* g1, whose every row is at depth 1, is the ABSTENTION CONTROL: **WRONG→RIGHT 0
  / RIGHT→WRONG 0 / GA buckets changed 0** — the law does not touch a flat
  generate scope at all.

## 5. What moved

Prediction, made from PRISTINE databases only and scored before a line of the
law existed (`PREDICT_R0.txt` Part 1): the whole surelog corpus holds **12**
cells whose golden side is a `ref_obj` where ours is a folded `constant` in an
elaborated gen-scope value slot, and every one of them is `Earlgrey_0_1`,
`GDEPTH 2`, `prim_lfsr.sv:308`, six per mode.  **uhdm2rtlil holds zero.**

MEASURED, `byteverify SELFCHECK=1`, patched vs this pass's OWN pristine sweep
(both binaries frozen `chmod 555` at immutable paths of the same length before
any sweep; every `cmds.txt` audited BY BINARY PATH — 0 of 1573 + 1462 name the
main-tree binary):

```
uhdm2rtlil  MOVERS 0 / 1358      SELFCHECK 1357/1358 flagged   <- as predicted
surelog     MOVERS 3 /  956      SELFCHECK  955/ 956 flagged
    ./default/Earlgrey_0_1     <- PREDICTED, the law
    ./testflags/Earlgrey_0_1   <- PREDICTED, the law
    ./default/Scoreboard       <- the documented ~50/50 COIN, proof below
```

No SeqDriver layout move (r10earl94 R2): the workroot path shape was held
identical between the two sweeps (`/tmp/r10earl95_wd_p0` vs `_p1`), which is the
`SEQDRIVER_PATH` discipline, and both SeqDriver databases are byte-identical.

**Scoreboard/default is the coin, and the proof does not lean on the citation.**
Twelve runs on the SAME sources, alternating binaries, `61dbb909a7e5` is the
PRISTINE sweep's hash and `1bb47cacd704` the patched sweep's:

```
run  1 pris 61dbb909a7e5   run  2 patc 61dbb909a7e5   run  3 pris 61dbb909a7e5
run  4 patc 61dbb909a7e5   run  5 pris 61dbb909a7e5   run  6 patc 1bb47cacd704
runs 7-12 pris 61dbb909a7e5 (six times)
```

The PATCHED binary produced the PRISTINE sweep's hash on two runs of three, so
the two hashes are the two faces of one coin and not a property of the change.
The order-blind attribution agrees: the sorted, path-normalised dumps of the two
sweeps' Scoreboard databases are byte-identical over 1 100 242 lines (0
differing lines), so the SET of dump lines never changed -- only its order.  And
`Scoreboard.default.cmp` is BYTE-IDENTICAL before and after.

CORPUS CENSUS re-scored over the same fixed universe, **golden side asserted
BYTE-UNCHANGED** (`md5(cen_sl_p0.g) == md5(cen_sl_p1.g)`, likewise u2r):

```
surelog     BOTH-SAME   2 822 528 -> 2 822 548
            MOVED-WRONG     3 285 ->     3 269
            GOLDEN-ONLY   264 680 ->   264 676
            OURS-ONLY     485 086 ->   485 094
uhdm2rtlil  the two census files are BYTE-IDENTICAL before and after
```

**WRONG→RIGHT 32, RIGHT→WRONG 0, AWAY-GOLDEN 0** on surelog; **0/0/0** on
uhdm2rtlil.  Eighteen cell rows disappear (6 GOLDEN-ONLY `ref_obj` rows we did
not have + the 12 predicted MOVED rows) and exactly ONE row appears, stated
loudly here because it is the pass's only one-sided addition:

```
OURS-ONLY  testflags/Earlgrey_0_1  RF|ELAB|2|IDX|LfsrDw|308:62-308:68|operation|308:62-308:70
    G [('-@-', 2)]      O [('-@-', 2), ('parameter@33:32-33:38', 2)]
```

Two surplus `ref_obj`s hanging off the pre-reduction operation at the
part-select bound.  The SLOT that reaches them is
`part_select|308:62-308:72|lr`, and that slot is `constant[INT:63]` on BOTH
sides — so the operation is no longer referenced by anything the judge walks:
the weakly-referenced TAIL (RESUME §9).  Filed as R1.

## 6. The heads after

```
Earlgrey_0_1  default    46 -> 112 cmp lines, 1 head   <- THE HEAD MOVED ON
Earlgrey_0_1  testflags  50 -> 112 cmp lines, 1 head   <- THE HEAD MOVED ON
```

Both modes now stop at the SAME new object, and it is **pre-existing, not
introduced**: `hmac_pkg.sv:17`, `logic_typespec` `sha_word_t` (golden) versus
`hmac_pkg::sha_word_t` (ours).  The PRISTINE database carries the identical
`hmac_pkg::sha_word_t` spelling — verified object for object with `ln95` on both
binaries — so this is an older divergence the `prim_lfsr` head had been masking.
It is the context-dependent-naming family the campaign memory warns against
"fixing" uniformly.  Filed as R0.

Every other named row's head log is byte-identical before and after
(`rowheads.sh`: SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
Rggen).

## 7. The boundary

`vwide95.sh` compiles EVERY `.sv`/`.v` under a COPY of `tools/probe`, at any
depth, in BOTH views, with BOTH frozen binaries, and byte-compares the
workdir-normalised dumps.  The file list is read on fd 3, every child gets
`</dev/null`, and PROCESSED is asserted.

```
PROCESSED=4294  identical=8208  DIFFERING=23  no_output=357
rc histogram   rc=0 15761   rc=3 684   rc=4 702   rc=139 28   rc=127 1
rc by side     0_A 7880 / 0_B 7881   3_A 342 / 3_B 342   4_A 351 / 4_B 351
               139_A 14 / 139_B 14   127_A 1
```

The rc histogram is SYMMETRIC side for side except one `rc=127` on the patched
side — a transient exec failure under a concurrent sweep, not a behaviour: the
arm it names (`r10vrgg14repro/cells/v3/dut.sv`, elab) re-runs `rc=0` on both
binaries and its normalised dumps are byte-identical.  That leaves **22
differing arms**, and every one of them is scored against ITS OWN
purpose-built Surelog golden with `arm95.sh` + `verd95corpus.py`
(`ARMS.r10earl95.txt`):

```
arm                view    WRONG->RIGHT  RIGHT->WRONG  no-golden-key
r10earl56 a1        plain/elab   6 /  6      0 / 0        0 / 0
r10earl56 a2        plain/elab   4 /  4      0 / 0        0 / 0
r10earl56 a5        plain/elab   6 /  6      0 / 0        0 / 0
r10earl56 v2        plain/elab   6 /  8      0 / 0        0 / 0
r10earl56 v6        plain/elab   4 /  4      0 / 0        0 / 0
r10earl58 a1        plain/elab  20 / 24      0 / 0        0 / 0
r10earl59 v59v2     plain/elab   0 /  0      0 / 0        1 / 1   (R3)
r10earl59 v59w2     plain/elab   0 /  0      0 / 0        6 / 6   (R3)
r10earl59 v59w3     plain/elab   8 / 16      0 / 0        0 / 0
r10v64    v4_homes  plain/elab  16 / 32      0 / 0        0 / 0
r10earl95 g3_pool   plain/elab  96 /138      0 / 0        0 / 0
```

and the JUDGE agrees on every one of them — `uhdm-cmp` cmp lines go DOWN or
stay equal, head count stays 1, on all 22:

```
a1_earl56 plain 23068->23014   a2_earl56 plain  7847-> 7811
a5_earl56 plain  6827-> 6773   v2_nestedsel56  5719-> 5665 / 5785->5771
v6_overreach56  8629-> 8593    a1_earl58 plain 146147->145967 / 139577->139549
v59v2_earl59    8207-> 8189 / 8637->8623      v59w2_shapes59  9289->9217 / =
v59w3_ports59  10917->10845 / 11827->11771    v4_homes64 15583->15439 / 16601->16489
g3_pool95      45858->44994 / 43492->43198
```

Every `no-golden-key` row is R3 (see `PREDICT_R0.txt`): golden's elaborated copy
lost the whole select or the whole Rhs to a reduction we do not perform, so the
key does not exist on the golden side and only the payload inside an OURS-ONLY
subtree changed.  Both binaries are equally unlike golden there.

## 8. The gates

All in `GATES.r10earl95.txt`, run with the two frozen binaries.

```
(1) build          pristine a7c25e51887a87b63fecd233fba489ab
                   patched  fe69ea2dfe5c0fd2bf6b21a4a8cb3f83
(2) goldens        23 PASS / 0 FAIL on BOTH binaries; SLANG_UHDM=/bin/false
                   gives 0 PASS / 23 FAIL (the comparator can see)
(3) u2r both modes 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL,
                   ct8rows 0 differing ROWS vs the committed baseline AND vs
                   this pass's own pristine sweep (status AND dump column)
(4) surelog both   471/466 CMP_EQUAL, 10/9 CMP_NOTEQUAL unchanged,
                   ct8rows 0 differing ROWS over 1588 vs the committed baseline.
                   NO row converted, so results/*.csv is untouched.
(5) byteverify     SELFCHECK=1, movers named and attributed (§5)
    canaries       canaries.sh ok=52 changed=0 absent=0 (surelog) and ok=8
                   changed=0 (u2r); ctcan2.sh ok=58 / ok=1, changed=0;
                   canaudit.sh audited=29 UNCOVERED=0 FENCE-BREACH=0
```

The four slang-fenced tests are never dispatched and are not spelled here;
`canaudit.sh` re-checks that on this directory.

### 7b. The boundary over this pass's own arms

The wide boundary was staged from a COPY of `tools/probe` taken before
`g4_kind95.sv` and `g5_hop95.sv` existed and before `g1`/`g2` were corrected
(an out-of-bounds index and a use-before-declaration made both binaries reject
them, so they counted as `no_output`).  `BOUNDARY_OWN.*` closes that gap over
the five arms in this directory, with the same instrument:

```
PROCESSED=5  identical=2  DIFFERING=8  no_output=0   rc=0 20 (all twenty runs)
identical : g1_sel95 plain + elab            <- the ABSTENTION CONTROL
differing : g2 / g3 / g4 / g5, both views    <- every one scored 0 RIGHT->WRONG
```
