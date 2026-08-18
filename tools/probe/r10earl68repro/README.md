# r10earl68 — § genvarWholeCaRhsFold68

**BASE `3175257`.  Earlgrey_0_1, BOTH modes.  The head earl67 named as R0 is
CLEARED — the whole 89-cell family, in both modes, with the two AFTER cmp logs
byte-identical; the new head is in `PREDICT_R0.txt`.**

Pristine binary md5 `ce3e5a94c3727c249cad47a83ac70a62`,
patched binary md5 `54adbbaef787ad399de94ddbb9439f6d`.
Golden caches (immutable, read-only): `00d4794526e44dc553f3` (default),
`d7348d2d2fe67abe767b` (testflags).

---

## 1. The head, decoded before any code

```
LHS: constant  id:990154   NO LOCATION AT ALL
     |vpiParent -> cont_assign (114:20-114:42)
     |vpiDecompile:0  |vpiSize:64  |UINT:0  |vpiConstType:9   (no typespec)
RHS: ref_obj (…gen_tree[2].gen_level[0].gen_leafs.gen_assign.offset) id:252319
     114:36-114:42  |vpiName:offset      (no vpiActual in the default view;
                                          bound to the loop parameter in elab)
```

`cont_assign::Compare` (UHDM/build/generated/src/cont_assign.cpp) runs
`VpiNetDeclAssign`, `VpiStrength0/1`, then the **singular**
`SafeCompare(lhs->Rhs(), rhs->Rhs(), context)`.  Both operands are **non-null**
with **different `UhdmType`**, so `BaseClass::Compare`'s type test fails first
and BaseClass.h:188's `(lhs != nullptr) && (rhs != nullptr)` arm names **both**
sides in full — neither the `<null>` singular arm nor a vector size mismatch.
Read the MK line, not the shape (RESUME §9).

The owner is `prim_arbiter_tree.sv:114`

```systemverilog
for (genvar level = 0; level < NumLevels+1; level++) begin : gen_tree
  for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
    if (level == NumLevels) begin : gen_leafs
      if (offset < N) begin : gen_assign
        assign idx_tree[Pa]  = offset;          // <-- the head
```

**The genvar is TWO generate blocks out from the read** (`gen_leafs`,
`gen_assign` sit between the `gen_level` loop and the cont_assign).  That
single fact is the whole pass: this emitter already folded a bare genvar Rhs
**at distance 0** and the predicate was `rsym0.getParentScope() == &blk`, so
the head — and its 88 siblings — never reached it.

> **Golden reduces the WHOLE Rhs of an elaborated cont_assign; a bare genvar
> read reduces to a LOCATION-LESS `constant vpiUIntConst` minted straight from
> the unrolling's `Value`, carrying no typespec, and then re-SIZED (and MASKED)
> by `adjustSize` against the Lhs typespec `bindVariable` can find.  We kept a
> `ref_obj` at every distance but 0, and at distance 0 we always minted size
> 64.**

## 2. The census: 89 cells, and the genvar-read position rule

Direct `.uhdm` reader, never `uhdm-dump` (Earlgrey's dump is >1 GB — the
earl61-67 rule).  `tscen68` is `r10earl67repro/tscen67.cpp` unchanged; the new
instrument is `gvcen68.py`, which keys the join on the positional route and
classifies every cell whose OUR side is a `ref_obj` naming one of the design's
21 genvar names.

**Calibration first (RESUME §9):** the golden re-read is byte-identical and the
golden-vs-golden multiset join is **0 differing cells / 162,259**.

Whole-design GENVAR-READ census, pristine binary (8,259 cells default /
7,536 testflags), by position:

| cells def / tf | position (route tail) | golden |
|---:|---|---|
| **89 / 89** | **`RHS` — the WHOLE Rhs** | **CONSTANT `ct 9 sz 64` no ts — THIS PASS** |
| 4683 / 4683 | `CA/…/idx` bit-select index | ref_obj KEPT |
| 0 / 261 | `CA/…/hp[0]/idx` inside a HIER_PATH | constant, but **LOCATED** — earl67's R1, a different mint (see `PREDICT_R0.txt`) |
| 2309 / 2309 | `CA/…/e[]` var_select element | ref_obj KEPT |
| 613 + 74 + 64 + 60 + 46 / … | operation operands (`op11/24/13/14/67`) | ref_obj KEPT |
| 2 / 2 | `LHS` | ref_obj KEPT |

**The whole-Rhs slice is 89 cells and golden folds 89 of 89, in both modes,
with ZERO exceptions** — and every one is the same shape
(`gen_level[N].gen_leafs.gen_assign`, `prim_arbiter_tree.sv:114` x 8 and
`rv_plic_target.sv:73` x 81).  The bit-select-index slice is 4,683 cells and
golden keeps the ref in every one, which is rgg14's law and this pass's
largest negative control.

## 3. Where it comes from, decoded not guessed

**Surelog, two functions.**

1. `UhdmWriter::writeCont_assign` (UhdmWriter.cpp ~2244).  When none of the
   pattern/operation arms fired (`simplified == false`) it runs
   `m_helper.reduceExpr` on the **whole Rhs**, and on success replaces the Rhs
   with the single resulting constant.  A bare genvar reduces through
   `CompileHelper::getValue` (CompileExpression.cpp ~966):

   ```cpp
   sval = instance->getValue(name);          // the unrolling's loop value
   if (sval && sval->isValid()) {
     UHDM::constant *c = s.MakeConstant();
     c->VpiValue(sval->uhdmValue());  setRange(c, sval, compileDesign);
     c->VpiDecompile(sval->decompiledValue());
     c->VpiConstType(sval->vpiValType());  c->VpiSize(sval->getSize());
   ```

   — a **fresh** constant with **no `populateCoreMembers`** (hence
   location-less) and **no typespec to copy from** (hence bare).  That is the
   opposite mint from earl67's localparam fold, which copies a `param_assign`
   Rhs *with* its located declaration typespec.  `getValue`'s answer for a
   genvar is `vpiUIntConst` at size 64.

   Distance is nowhere in this path: `reduceExpr` asks the *instance* for the
   name, and the gen-scope instance inherits its parents' mapped loop values.
   Hence distances 0, 1, 2 and 3 all fold (`GRIDS_68.txt` §A).

2. `CompileHelper::adjustSize` (CompileHelper.cpp:3949), applied to that
   constant with `tps` = the LHS's typespec.  For a plain `ref_obj` Lhs,
   `writeCont_assign` sets `tps` from
   `CompileHelper::bindVariable(component, m, name, …)`; the scope-walking
   overload (CompileStmt.cpp:3089) switches on **function / task / begin /
   module_inst ONLY** — there is **no `uhdmgen_scope` case and no
   `uhdminterface_inst` case** — so it walks a gen_scope's parent chain
   straight PAST every gen-local declaration and stops dead at an interface.
   With `tps == nullptr` `adjustSize` returns immediately and the 64-bit mint
   survives; with a `tps` it re-sizes to `Bits(tps)` and **masks** the value.

**Golden itself**, on three arms, reproduces both halves cell for cell —
`GRIDS_68.txt` §D/§E is the whole ladder:

| Lhs | golden size |
|---|---|
| `logic [7:0]` module-level | 8 |
| `logic [3:0]` module-level | 4 |
| `logic` module-level, iteration i=5 | **1**, value **UINT:1** (masked) |
| `logic [99:0]` | 100 |
| `wire [7:0]` (a net) | 8 |
| `int` / `integer` | 32 |
| `byte` | 8 |
| `bit [5:0]` | 6 |
| a module **port** | its width |
| `real` | **32** (UHDM `ExprEval.cpp:1304`) |
| `shortreal` / `realtime` | **64** — r10v68 CORRECTION: `shortreal` gets NO typespec at all and `realtime` becomes a `time_var` (Bits 64); only `real` is 32 |
| a bare `var d;` or an IMPLICIT net | **64** — r10v68 CORRECTION: Surelog writes those declarations with no typespec |
| a **gen-local** variable (any width) | **64** |
| an **interface-level** variable | **64** |
| `arr[i]`, `wide[7:0]`, `wide[i+:8]`, `{ca,cb}`, `vst.lo` | **64** |

## 4. The law and the code

> **§ genvarWholeCaRhsFold68** — the WHOLE Rhs of an ELABORATED gen-scope
> cont_assign that is a bare read of a GENVAR declared by **any generate loop
> on the emission block's own parent chain** is replaced by a **location-less
> `vpiUIntConst`** carrying **no typespec**, whose SIZE is 64 unless the Lhs is
> a plain reference to a net/variable of the enclosing **module** body **whose
> DECLARATION Surelog gives a typespec**, in which case it is that
> declaration's width and the value is masked to it.
>
> **r10v68 (verifier) amendment, measured, shipped in `.verified.patch`:** the
> "declaration Surelog gives a typespec" clause is load-bearing and was missing
> here.  Four declaration shapes carry no usable typespec and keep 64 —
> an **implicit net**, a bare **`var d;`**, a **`shortreal`** and a
> **`realtime`** (the last is a `time_var`, Bits 64) — while only **`real`**
> is sized 32.  Sizing all floating kinds at 32 and every module-body
> declaration at its slang bit width moved FOUR pristine-RIGHT distance-0
> cells AWAY from golden (`r10v68repro/v11_d0.sv`).

ONE file, one new helper and one predicate (r10v68 CORRECTION: the shipped
diff is **+99/-3** lines in **one** file, not +81/-8 in two), no behaviour
outside the gate:

* `src/ModuleEmit.cpp`, new file-static `caLhsAdjustSize68` — the `adjustSize`
  half, with the `bindVariable` decode in the comment.
* `src/ModuleEmit.cpp`, `emitGenScopes`'s `emitBlock` cont_assign loop — the
  predicate `rsym0.getParentScope() == &blk` becomes a walk up the **generate
  blocks only** (it stops at the first non-generate scope, so a module-body or
  package parameter can never be taken), plus `isFromGenvar()`, plus the size.

### The fences, and how each was found

**(1) The `isFromGenvar()` + generate-only walk.**  Widening the scope test is
the whole risk of this pass: a gen block's parent chain ends in an
`InstanceBody`, and stopping there is what keeps § genLpUseFoldParentScope47's
and earl64's parameter families out of this arm.  The pre-existing
`!ParameterDeclaration` test (which excludes real `localparam`s) is kept as
well, so the two agree at distance 0 and nothing that folded before stops
folding.

**(2) The SIZE, which is a fence in both directions.**  Before this pass we
minted 64 unconditionally; golden mints 64 only when `bindVariable` fails.  The
arm cell `assign net_d0 = i;` at **distance 0** was therefore already wrong
(ours 64, golden 8) — a pre-existing defect the widened arm would have
multiplied.  Modelling `adjustSize` fixes the old cells and the new ones in one
rule, and `MemoryPort`'s `assign a[i] = i;` (a select Lhs) is the corpus proof
that the 64 arm still exists — see below.

**The fence was hunted corpus-wide BEFORE the patched binary was gated**
(`gvfence68.cpp` + `fencescan68.sh`, run over all **2,314 pristine databases**
of this pass's own pristine sweep).  Only cells whose gen-scope cont_assign Rhs
is a bare `ref_obj` (the fold could take it) or an already-minted LOCATION-LESS
constant (the size rule could re-decide it) can move; **33 databases** carry
either, and every one was read (r10v68 CORRECTION: the verifier's rerun of the
same instrument over the same 2,314 pristine databases counts **51** — 41 with a
`CAND`, 12 with a `FOLD`, 2 with both — and the `FOLD` list below misses
`FuncBindGen` (surelog, CMP_EQUAL, `sz 32` from another fold path).  Neither
changes the outcome: both corpora byteverify to Earlgrey-only movers.):

* every `CAND` (bare-`ref_obj` Rhs) outside Earlgrey names a **net or
  variable**, never a genvar (`Y`, `tmp`, `mem`, `t_rs1`, `wvalid`, `value`,
  `counter_q`, …, 106 names over 33 databases) — none is foldable;
* the `FOLD` cells are **`MemoryPort`** (u2r, CMP_EQUAL, `assign a[i] = i;`
  with `output logic [31:0] a [10]` — a SELECT Lhs, so 10 x `sz 64` and the
  size rule leaves them alone), **`DoubleLoop`** (surelog, CMP_EQUAL,
  `assign ys = i + j;` — an OPERATION Rhs folded by another path, `sz 3`),
  **`CastInFunctionInGenBlock`** and
  **`ParameterInitializedByOperationOnPackageParametersAndUsedInGenscope`**
  (u2r, CMP_EQUAL, a function fold and a `BIN:1` — neither is the genvar arm).

**Predicted mover set, by name, from the pristine databases alone:
`Earlgrey_0_1` default + testflags and NOTHING ELSE.**  Both corpora came back
exactly that (plus the documented `Scoreboard`/default order coin).

## 5. Arms (the grid), scored against golden

`a1_gv68.sv` — the head's own shape minimised (nested `gen_d0..g_d3` chains) x
distances 0/1/2/3 x positions (whole Rhs, `i+1`, concat, ternary predicate,
bit-select index, ips base, computed ips base, cast, Lhs bit-select index,
operation-with-a-net, net bit-select) x nested two-genvar loops x a
localparam-of-genvar contrast x Lhs positions.
`a2_lhs68.sv` — the `adjustSize` ladder: 10 declared Lhs types (incl. a 1-bit
target that MASKS a value of 5, a 100-bit target and a `wire`) x 5 select-Lhs
kinds x an INTERFACE gen scope x two CHILD instances of the same module.
`a3_bind68.sv` — the `bindVariable` ladder: module-level / gen-local / one gen
block deeper / interface-level / module PORT / unpacked-array element / `real`
/ parenthesised genvar / **net-decl-assign** (golden keeps the ref in the
variable's `Expr` — a negative control this pass must not touch).

`score68.py` 3-way multiset join (golden / pristine / patched), payload reduced
to the fields the judge reads and **carrying no span** (`nospan68.sh` —
earl60's `attrv60.py` lesson):

```
ARM a1_gv68   plain view  cells 280  STILL-RIGHT 210  TO-GOLDEN 29  AWAY 0  MOVED-WRONG 0
ARM a1_gv68   elab  view  cells 280  STILL-RIGHT 131  TO-GOLDEN 29  AWAY 0  MOVED-WRONG 0
ARM a2_lhs68  plain view  cells 176  STILL-RIGHT 147  TO-GOLDEN 27  AWAY 0  MOVED-WRONG 0
ARM a2_lhs68  elab  view  cells 176  STILL-RIGHT 109  TO-GOLDEN 21  AWAY 0  MOVED-WRONG 0
ARM a3_bind68 plain view  cells 140  STILL-RIGHT 111  TO-GOLDEN 27  AWAY 0  MOVED-WRONG 0
ARM a3_bind68 elab  view  cells 140  STILL-RIGHT  83  TO-GOLDEN 24  AWAY 0  MOVED-WRONG 0
```

**Zero AWAY-GOLDEN and zero MOVED-WRONG in every arm and every view.**  After
the patch, **every** `RHS` cell of `a2_lhs68` and **every** `RHS`/`VE` cell of
`a3_bind68` is byte-identical to golden in the plain view — the whole
`adjustSize` ladder, the mask, the gen-local/interface/select 64s, the `real`
32, and the untouched net-decl-assign.  The negative controls all held: the
bit-select index, the ips base, the ternary with a net, the operation with a
net, the Lhs index and the localparam contrast are unchanged.

`a1_gv68`'s remaining STILL-WRONG cells are the ranked R4 residues (the concat
and cast whole-Rhs reduces, and the gen-scope LOCALPARAM whole-Rhs read) — see
`PREDICT_R0.txt`.

## 6. Gates (all run in this worktree, both binaries frozen at 555)

| gate | result |
|---|---|
| build both, md5 | `ce3e5a94…` pristine / `54adbbae…` patched |
| `tests/check_goldens.sh` (SLANG_UHDM exported per binary) | **PASS 23 / FAIL 0** on BOTH binaries |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags / default, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| `ct8rows` u2r tf vs **committed** `results/gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** |
| `ct8rows` u2r tf + def vs this pass's own pristine sweep | **PASS, 0 differing rows** (status AND dump) |
| `byteverify SELFCHECK=1` u2r (1358 DBs) | **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| surelog `--mode both` (1588 rows, 956 DBs) | status histogram **IDENTICAL** to pristine (470/466 CMP_EQUAL, 11/9 NE) |
| `ct8rows` surelog vs **committed** `results/golden_surelog.csv` | **PASS, 0 differing rows** (status AND dump, both modes) |
| `ct8rows` surelog vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` surelog (956 DBs) | **MOVERS 3 / 956** = `Earlgrey_0_1` default + testflags (the PREDICTED set) + ONE order-only row (r10v68 CORRECTION: the verifier's own sweeps name `SeqDriver`/testflags, not `Scoreboard`/default — a 40-line swap of two `uvm_pkg` typespecs INSIDE the weaklyReferenced tail, order-blind diff **0 lines**, cmp head unchanged at 99202/1) |
| Earlgrey both modes | head **CLEARED**, 32 -> 216 lines, 1 head each, BEFORE logs byte-identical and AFTER logs byte-identical |
| whole-design census, both modes | **89 TO-GOLDEN, 0 AWAY-GOLDEN, 0 MOVED-WRONG**, and those 89 are the ONLY cells that changed (178 census lines per mode) |
| golden-vs-golden calibration | 0 differing cells / 162,259; golden re-read byte-identical |
| corpus fence scan (2,314 pristine DBs) | 33 databases carry a movable-shaped cell; every one read and refuted by name; predicted movers = Earlgrey only |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs by md5 | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME** (both modes); SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `rowheads.sh` | **only Earlgrey moved** (32 -> 216); SeqDriver 99202, SimpleUVM/Scoreboard 99106, MiniAmiq 99202, BuildUVMPkg 52, Rggen 683 all unchanged |
| WIDE boundary (3,101 `.sv`/`.v`, PROCESSED == LISTED, both views, both binaries) | see §6b |
| per-DIRECTORY boundary (1,407 dirs, both views) | see §6b |

`cmds.txt` audited by BINARY PATH in every arm (1458 u2r + 1523 surelog lines
per binary, every one `/tmp/r10earl68_p{ristine,atched}.bin`), `SLANG_UHDM`
exported explicitly per binary, `GOLDEN_DEFER` unset, `results/*.csv` never
written.  The 2 `rc=-11` rows in the surelog sweep are present on BOTH binaries
— pre-existing, not introduced.

## 7. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `tscen68.cpp` — whole-design expression census, direct `.uhdm` reader,
  positional route key (unchanged from `r10earl67repro/tscen67.cpp`).
* `cen68.sh` / `nospan68.sh` — span normalisation, and the judge-invisible
  field strip before scoring.
* `sfam68.py` — the (golden kind, ours kind) pair census and the ranked
  "golden folds / we do not" superfamily.
* `gvcen68.py` — **new**: the GENVAR-READ census.  Multiset join on the
  positional key, restricted to cells whose OUR side is a `ref_obj` naming one
  of the design's genvars, bucketed by position with golden's kind + judge
  fields.  This is the instrument that proved the position rule (89/89 fold at
  the whole Rhs, 4,683/4,683 keep at a bit-select index).
* `gvfence68.cpp` — **new**: the corpus fence scanner.  Reports every ELAB
  gen-scope cont_assign whose whole Rhs is a bare `ref_obj` or a
  LOCATION-LESS constant, i.e. every cell this law could move, from a `.uhdm`
  directly.
* `fencescan68.sh` — runs it over a whole sweep workdir.
* `score68.py` — 3-way multiset join, TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
  STILL-RIGHT / STILL-WRONG.
* `runarm68.sh` — one arm, Surelog + one binary in BOTH views.
* `earl68.sh` — one Earlgrey run, one binary, md5 printed, golden from cache.
* `vwide68.sh` / `vdir68.sh` — the recursive and per-directory boundaries; list
  on fd 3, children `</dev/null`, PROCESSED asserted.
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `byteverify.sh`,
  `rowheads.sh` — the standard battery.
* `GRIDS_68.txt` — the full distance x position x Lhs-type x bind grid as
  measured on golden.
* `HEAD_R0_{BEFORE,AFTER}_{default,testflags}.cmp` — the four cmp logs.
