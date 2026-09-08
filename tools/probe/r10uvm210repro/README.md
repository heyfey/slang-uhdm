# r10uvm210 — § `pkgParamRefRhs210` — **THE BRIEFED LAW IS ALREADY LAW-COMPLETE: OUTSIDE THE SLANG FENCE, NOT ONE PACKAGE `param_assign` Rhs IN EITHER CORPUS IS A `ref_obj` IN GOLDEN AND A FOLD IN OURS** — and the SeqDriver ×2 50-line head is a **DEF/ELAB VIEW CROSSING**, not a fold

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; the corpus censuses walk a sweep workdir that contains them,
so `scrub210.sh` redacts their names out of every artifact — reading the fence
list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `18d0800c` |
| pristine binary | md5 `1644b8e244f1b5caca4f876ebc99d1e9`, built `-j 2` from this pass's OWN worktree at a clean `18d0800c` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | **there is none.** The production surface of this pass is EMPTY (§ 6), so the "patched" binary would be the same file with the same md5, and a two-binary sweep would be a tautology rather than a measurement. That is stated in `GATES.r10uvm210.txt`, not hidden. |
| production surface | **NONE — 0 files, 0 lines.** |
| probe surface | `tools/probe/r10uvm210repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build | **SeqDriver default and testflags, 50 cmp lines / ONE head each**, the two logs identical modulo object ids — exactly the head r10uvm207 named as R0. |
| every other row's head | SimpleUVM ×2 **86**, Scoreboard/default 95, MiniAmiq ×2 **112**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the brief's law | **REFUTED, by the official `param_assign::Compare` on the cell itself.** Golden's def-view `uvm_pkg` carries `ref_obj UVM_SET` with `vpiActual` = the `operation` at 216:31-216:48, and **so do we, in both modes**; the cell compares EQUAL with a fresh CompareContext in all four package listings (§ 2). |
| the corpus population of the briefed law | **EMPTY on every row this campaign can act on.** 956 surelog databases and 1358 uhdm2rtlil databases, every package/module `param_assign` keyed owner-kind × owner-name × view × Lhs name × Lhs span × Rhs FORM × ref-ACTUAL kind: the only two `REF`-form cells golden carries and we do not sit on ONE **slang-fenced** row, in both modes, and there are none anywhere else (§ 4). uhdm2rtlil is clean outright — 68676 cells, ONLY-GOLDEN 0, ONLY-OURS 0, 0 rows with any one-sided cell. |
| what the head IS | a **DEF/ELAB VIEW CROSSING**. In every one of the four package listings, in both modes, **exactly 7 of 45 `param_assign` cells differ, and index 35 — the cell the cmp log names — is never one of them**. The 7 are precisely the cells whose Rhs `constant` carries a typespec with a non-null `Instance`, i.e. the cells that RECURSE into the package (§ 3). |
| the crossing object, named | golden carries a DEF-view `unsupported_typespec` for the type parameter `REQ` (uvm-1.2 `seq/uvm_sequencer.svh:164`, `REQ t;` inside `uvm_sequencer::stop_sequences`) whose `Instance` is the **DEF** `uvm_pkg` (id 85672, reached from `uvm_pkg::uvm_sequencer::stop_sequences::t`); **every one of ours names the ELABORATED `uvm_pkg`**. Sixteen `REQ`/`RSP` typespec keys have that shape. That is R0. |
| the golden grid | **8 arms × 2 views = 16 arm-views, one REAL Surelog golden each, 0 nonzero rcs, golden-vs-golden CALIBRATION null in every cell.** In the PARSE view — the view every corpus golden in this family is built in — arms **B, C, D, E, G, H are 0 ONLY-GOLDEN / 0 ONLY-OURS**: our emitter already reproduces golden's def-view `ref_obj` *and its `vpiActual`* for parameter-ref, literal and expression defaults, in the declaring package, in an importing package, in an importing module and under a `$unit`-scope import. The only cells that move are QUALIFIED ENUM-CONSTANT defaults (arms A and F, § 5 / R2). |
| byte movers | **0 / 956** surelog and **0 / 1358** uhdm2rtlil — by construction, there being no second binary; the `SELFCHECK` negative control fires at 955/956 and 1357/1358, so the comparator is not asleep. |
| gates | goldens **23 PASS / 0 FAIL**, `/bin/false` negative control **23 FAIL**; uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in BOTH modes**, `ct8rows` PASS against the committed testflags baseline; surelog 1588 rows with the committed status histogram reproduced exactly (**473/8 default, 468/7 testflags**); canaries `ok=50`/`ok=8`, `ctcan2` PASS ×2, `canaudit` PASS `audited=29 UNCOVERED=0 FENCE-BREACH=0`; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`. |
| the four protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2 and `Earlgrey_0_1` ×2 — **CMP_EQUAL with rowheads 0 lines / 0 heads on all four**, and the census scores both columns: `BuildUVMPkg` ×2 carry **no one-sided cell at all**; `Earlgrey_0_1` ×2 carry one-sided cells that exist on the PRISTINE binary at BASE and are invisible to the judge, which reads those rows EQUAL (§ 7). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `18d0800c` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`1644b8e2…`). `check_goldens.sh` reads 23 PASS / 0 FAIL with the `/bin/false`
negative control at 23 FAIL; both uhdm2rtlil sweeps reproduce their baselines
exactly; the surelog sweep reproduces `results/golden_surelog.csv` row for row
except two informational dump-column cells (§ 7). All of that before a line was
written.

`rowheads.sh` on that sweep (`GATES.r10uvm210.txt`):

```
SeqDriver ×2 50 · SimpleUVM ×2 86 · Scoreboard/default 95 · MiniAmiq ×2 112
BuildUVMPkg ×2 0 · Earlgrey_0_1 ×2 0 · Rggen/default 0
```

SeqDriver's head (`head_pris_SeqDriver.default.cmp`, testflags identical modulo
ids):

```
LHS: ref_obj: (uvm_pkg::UVM_SET), id:61413, line:217:31, endln:217:38
     |vpiParent: \_param_assign: , id:61409, line:217:11, endln:217:38
     |vpiName:UVM_SET  |vpiFullName:uvm_pkg::UVM_SET
     |vpiActual: \_operation: , id:61405, line:216:31, endln:216:48
RHS: constant: , id:6275, line:217:31, endln:217:38
     |vpiParent: \_param_assign: , id:6274, line:217:11, endln:217:38
     |vpiDecompile:131078 |vpiSize:32 |UINT:131078
     |vpiTypespec: \_ref_typespec: (uvm_pkg) -> int_typespec
     |vpiConstType:9
```

The source is uvm-1.2 `base/uvm_object_globals.svh:216-217`:

```systemverilog
parameter UVM_SET           = UVM_START_FUNCS+1;   // 216
parameter UVM_SETINT        = UVM_SET;             // 217
```

`UVM_SET` is a plain parameter, not an enum constant, and `vpiActual` is its own
def-view Rhs `operation`. The brief's reading of the SHAPE is right. What it got
wrong is who emits it.

---

## 2. THE EDGE, FIELD BY FIELD — **WE ALREADY EMIT GOLDEN'S `ref_obj`**

`ct210own --slots <db> UVM_SETINT` lists every listing in a database that holds
a `param_assign` of that name, with the Rhs face and — new in this pass's
owner-finder — a `ref_obj`'s `Actual_group` kind and span, because
`ref_obj::Compare` READS `Actual_group` (generated `ref_obj.cpp`). Both
databases, both modes, in `EDGE.r10uvm210.txt`. The one row that matters:

```
GOLDEN  defpkg  package(uvm_pkg)  PA[35]/45
        RHS=ref_obj@217:31-217:38 name=UVM_SET full=uvm_pkg::UVM_SET ACTUAL=operation@216:31-216:48
OURS    defpkg  package(uvm_pkg)  PA[35]/45
        RHS=ref_obj@217:31-217:38 name=UVM_SET full=uvm_pkg::UVM_SET ACTUAL=operation@216:31-216:48
```

Byte for byte the same form, the same name, the same fullname, the same actual
KIND and the same actual SPAN. Every other listing on both sides — the
elaborated `uvm_pkg`, the def and elaborated `adpcm_pkg`, the def and elaborated
`work@top_tb` (twice each, `imported=uvm_pkg` and `imported=adpcm_pkg`) and the
five `adpcm_*` class bodies — carries the folded `constant 131078`, on BOTH
sides.

And the official judge agrees. `ct210sub … cells` runs the generated
`param_assign::Compare` on each index of a listing with a **FRESH
CompareContext** (a whole-object compare stops at the first failure and its
`m_visited` then hides every later one — `BaseClass.h`'s `m_visited` is keyed on
the LHS). `ROUTE.r10uvm210.txt`, all four package listings, both modes:

```
PARAM_ASSIGNS sizes L=45 R=45      PARAM_ASSIGNS DIFFERING 7 / 45
```

and **index 35 is not one of the 7**, anywhere.

---

## 3. WHAT THE HEAD ACTUALLY IS — A DEF/ELAB VIEW CROSSING

The 7 that do differ are `UVM_HDL_MAX_WIDTH`, `uvm_mgc_copyright`,
`uvm_cdn_copyright`, `uvm_snps_copyright`, `uvm_cy_copyright`,
`uvm_nv_copyright`, `uvm_revision` — indices 0..6 — and every one of them fails
at the SAME deep pair, golden `ref_obj` id 61413 against our `constant` id 6275.
They are not seven bugs. They are the seven cells that RECURSE:

```
ct210inst --pa-inst GOLDEN 59742   ->  cells=45 WITH-INSTANCE=7
ct210inst --pa-inst OURS   146     ->  cells=45 WITH-INSTANCE=7
```

`WITH-INSTANCE` counts the cells whose Rhs `constant` carries
`ref_typespec -> <atom>_typespec` with a non-null `Instance`, and
`typespec::Compare` READS `Instance` — so those cells hand the judge the whole
package and are scored on it. The count matches the differing count exactly, on
both sides.

Follow that recursion and the crossing appears. `ct210inst --rhsof`:

```
GOLDEN 61413 -> ONE listing:   package uvm_pkg  ALLPKG   PA[35]
OURS   6275  -> SIX listings:  package uvm_pkg  TOPPKG   PA[35]
                               class_defn adpcm_driver / adpcm_seq_item /
                               adpcm_sequencer / adpcm_test / adpcm_tx_seq  PA[35]
```

For the judge to print that pair, an ancestor pair must be
(golden's **DEF** `uvm_pkg`, our **ELABORATED** `uvm_pkg`) — same name, same
def-name, so `package::Compare` walks straight in and meets golden's def-view
`ref_obj` against our elaborated `constant` at index 35.

`ct210inst --tsinst` names an object that produces exactly that crossing. For
the type parameter `REQ` at uvm-1.2 `seq/uvm_sequencer.svh:164` (`REQ t;` in
`uvm_sequencer::stop_sequences`), Surelog's `CompileType` falls through to its
catch-all and mints an `unsupported_typespec` NAMED as written:

```
GOLDEN  unsupported_typespec|REQ|164:3  ->  ALLPKG:uvm_pkg   (id 85672)
                                        ->  TOPPKG:uvm_pkg   ×5
OURS    unsupported_typespec|REQ|164:3  ->  TOPPKG:uvm_pkg   ×4      (NO def-view copy)
```

and `ct210inst --refto GOLDEN 85672` shows who holds golden's def-view copy:

```
REFTS full='uvm_pkg::uvm_sequencer::stop_sequences::t'
   parent ref_var 't' id=85673 @164:7
   grandp begin '' id=85671 @165:3
```

— the DEF-view body of that method. Sixteen `REQ`/`RSP` typespec keys have the
same shape (`ROUTE.r10uvm210.txt` §E). **That is the family the head belongs
to, and it is a def-view class-body family, not a ParamEmit one.**

---

## 4. THE CENSUS — THE BRIEFED POPULATION IS EMPTY, CORPUS-WIDE

`cen210.sh` keys every package/module `param_assign` in a database as

```
<owner kind> | <owner name> | <view> | <Lhs name> | <Lhs line:col> | <Rhs FORM> | <ref ACTUAL kind>
```

`Rhs FORM` is REF / CONST / OP / OTHER — the DEFAULT FORM the brief asked the
split to be keyed on — and the ACTUAL column is the `ref_obj::Actual_group`
kind, which the judge reads. The DEF/ELAB view IS in the key on purpose: the
whole question is which view keeps the reference, and both producers label the
two package listings the same way. The OWNER NAME is in the key because without
it a golden `CONST` in one owner and an ours `CONST` in a DIFFERENT owner cancel
— measured: adding the owner name turned grid arm F from 2 one-sided cells per
view into 3.

**The head's own row** (`FORMS.SeqDriver.r10uvm210.txt`):

```
SeqDriver/default    golden=590 ours=590  AGREE=590  ONLY-GOLDEN=0  ONLY-OURS=0
SeqDriver/testflags  golden=590 ours=590  AGREE=590  ONLY-GOLDEN=0  ONLY-OURS=0
```

The entire design holds exactly **two** `REF`-form cells, and both agree in form
AND actual kind on both sides:

```
K package|uvm_pkg|defpkg|UVM_SETINT   |217:11|REF|operation
K package|uvm_pkg|defpkg|UVM_END_FUNCS|220:11|REF|operation
```

**Both corpora** (`CENSUS.surelog.r10uvm210.txt`, `CENSUS.u2r.r10uvm210.txt`):

```
surelog     956 databases   AGREE 52724   ONLY-GOLDEN 37   ONLY-OURS 3123   rows with any one-sided cell 27 / 956
uhdm2rtlil 1358 databases   AGREE 68676   ONLY-GOLDEN  0   ONLY-OURS    0   rows with any one-sided cell  0 / 1358
```

The 37 ONLY-GOLDEN cells break down as **29 `CONST`, 4 `OP`, 2 `NONE`, 2 `REF`**,
and **both `REF` cells — the only two in either corpus — sit on ONE
slang-fenced row**, in both modes, together with the two `NONE` cells. This pass
never dispatches that row; it is fenced for reasons that predate it, and its
name is redacted out of every artifact here by `scrub210.sh`. Outside the fence
the 33 remaining ONLY-GOLDEN cells are `OP` and `CONST` on two rows in other
families (an anchor-span difference and one elaborated fold) plus thirteen on
`Earlgrey_0_1`, which the judge reads CMP_EQUAL in both modes.

**No unfenced row carries a `REF`-form cell that golden has and we do not.**
None of `SeqDriver`, `SimpleUVM`, `MiniAmiq`, `Scoreboard`, `BuildUVMPkg` or
`Rggen` appears among the 27 rows at all — every one of them scores
`ONLY-GOLDEN=0 ONLY-OURS=0` (SeqDriver 590 cells, SimpleUVM 365, MiniAmiq 815,
Scoreboard 185, BuildUVMPkg 89, Rggen 7547, all AGREE).

*So there is nothing for a gated unfold to do.* A patch here would have moved
zero corpus cells by construction, and the "MOVED-WRONG 0 / AWAY 0" the brief
asks for is satisfied trivially and vacuously — which is exactly why this pass
does not ship one.

---

## 5. THE GOLDEN GRID (8 arms × 2 views, one REAL Surelog golden each)

`grid210.sh` + `grid210/`. Every arm gets `-parse -d coveruhdm -nobuiltin
-nocache`, then the same again with `-elabuhdm`, then our binary, then the
official `uhdm-cmp` and the FORM census with golden-vs-golden CALIBRATION run
FIRST in every cell. `GRID.r10uvm210.txt`:
`ARM-VIEWS SCORED: 16`, `NONZERO RCs: 0`, `TOTAL CALIB non-null: 0`.

| arm | what it varies | parse view | elab view |
|---|---|---|---|
| **A** `g210_a_forms` | every default form in the declaring package: literal, typed literal, expression, bare ref, ref-to-ref, ref-to-expression, qualified cross-package ref, ENUM CONSTANT, string, parenthesised ref | **1 / 1** (the enum cell, R2) | 6 / 6 |
| **B** `g210_b_chain` | the corpus chain at 1/1000 scale (the `UVM_MACRO_EXTRAS → … → UVM_SET → UVM_SETINT` shape, plus a bare ref whose referent is a literal) | **0 / 0** | 3 / 3 |
| **C** `g210_c_pkgimp` | THE CORPUS TOPOLOGY — an importing PACKAGE and an importing MODULE over arm B, i.e. SeqDriver's `package adpcm_pkg; import uvm_pkg::*;` + `module top_tb; import …;` | **0 / 0** | 2 / 2 |
| **D** `g210_d_modimp` | module-only importer (the control for C's importing-package column) | **0 / 0** | 2 / 2 |
| **E** `g210_e_unitimp` | the `$unit`-scope wildcard import — the measured ACTUAL distinguisher | **0 / 0** | **0 / 0** |
| **F** `g210_f_enum` | enum-constant defaults: bare member, QUALIFIED member, typed, expression, and a member read from an importing package | **3 / 3** (R2) | 3 / 3 |
| **G** `g210_g_clsty` | the R0 shape — a package class method with a TYPE-PARAMETER-typed local | **0 / 0** | 1 / 1 |
| **H** `g210_h_expr` | THE MUST-STAY CONTROL — literal, typed literal, string, `+`, shift, ternary, concat, sized vector: every Rhs golden FOLDS | **0 / 0** | **0 / 0** |

Read the parse column first: it is the view every corpus golden in this family
is built in (SeqDriver's `.sl` carries no `-elabuhdm`, so
`scripts/verify_golden.py` builds a `-parse` golden). Six of the eight arms are
**identical on the form key**, including the corpus topology and the must-stay
control. Arm H is the "a Rhs a golden folds MUST STAY FOLDED" arm and it does.

Two things the grid found that the corpus does not contain:

* **the `-elabuhdm` ACTUAL.** With `-elabuhdm`, golden re-points the DEF-view
  `ref_obj`'s `Actual_group` to the referenced **`parameter`**; we keep the
  parse-view binding (the referent's own Rhs object). **13 cells** — arm A's
  `A_REF` `A_TREF` `A_REFREF` `A_REFEXPR` `A_PAREN`, arm B's `B_SETINT`
  `B_END_FUNCS` `B_REFLIT`, arm C's `C_SETINT` `C_REFLIT`, arm D's `D_REF`
  `D_REFLIT`, arm G's `G_REF` (the sixth elab cell of arm A and all three of
  arm F are R2, not this). Producer decoded in `DECODE.r10uvm210.txt` §2
  (`ElaboratorListener::enterPackage` seeds `paramMap` from `Parameters()`,
  where `enterModule_inst` and `enterInterface_inst` seed it from
  `Param_assigns` as name → `Rhs()`). Arm E shows we already reproduce BOTH
  bindings where a `$unit` import forces the `parameter` form.
* **R2, the qualified enum-constant default** — see below.

The per-arm `uhdm-cmp` VERDICT column reads CMP_NOTEQUAL on all 16 arm-views and
is **not** the arm scorer here: `-nobuiltin` makes golden's
`design->AllPackages()` one entry shorter than ours, so every arm's head is that
vector-size mismatch. The FORM census is the scorer, exactly as r10uvm201's grid
used `ct201cen` rather than the cmp verdict.

---

## 6. WHY THE PRODUCTION SURFACE IS EMPTY

The bar for a landing is that the head clears or the family closes corpus-wide
(RESUME §7). This pass closes the family: the briefed law is already implemented
and its corpus population is empty on both corpora. The head does not clear
because the head is not in this family — it is the def-view `Instance` crossing
of § 3, whose repair is a per-view mint of the class-body typespecs, a different
surface (TypeEmit / the def-view class-method-clone family) and a different
pass. Writing a "gated unfold" into `ParamEmit.cpp` to satisfy the brief's
shape would have changed zero corpus cells, cleared no head, and left a gate in
the tree that no measurement asked for.

R2 (qualified enum-constant defaults) IS a real divergence and IS in this
family, but its corpus population is also **zero** — it appears only in this
pass's own arms. It is recorded below with its Surelog decode so a future pass
can take it deliberately rather than discover it.

---

## 7. GATES, AND BOTH COLUMNS OF THE FOUR PROTECTED ROWS

Full transcript in `GATES.r10uvm210.txt`.

* binary md5 `1644b8e244f1b5caca4f876ebc99d1e9`, identical to the main tree's
  `build/slang-uhdm` at `18d0800c`; every `cmds.txt` in both sweep workdirs
  names the frozen `/tmp`-path binary and nothing else (audited BY PATH).
* `check_goldens.sh` 23 PASS / 0 FAIL with `SLANG_UHDM` exported explicitly;
  `SLANG_UHDM=/bin/false` gives 23 FAIL.
* uhdm2rtlil, both modes: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**.
  `ct8rows results/gate_uhdm2rtlil.csv` PASS — every row byte-identical to the
  committed baseline. `results/` carries no default-mode uhdm2rtlil baseline
  (every committed row there is `mode=testflags`), so the default arm is scored
  by that histogram and by `byteverify`.
* surelog, `--mode both`, 1588 rows: status histogram reproduced exactly —
  `473 CMP_EQUAL / 8 CMP_NOTEQUAL` default, `468 CMP_EQUAL / 7 CMP_NOTEQUAL`
  testflags. **NO ROW WAS CONVERTED.** Two row-SIDES differ from the committed
  baseline and both are the informational uhdm-dump column only:
  `Earlgrey_0_1,default` and `Earlgrey_0_1,testflags`, `CMP_EQUAL/differ` →
  `CMP_EQUAL/`, the recorded uhdm-dump TIMEOUT under sweep load that r10uvm207
  saw as well — on the PRISTINE binary, which is the main tree's own binary at
  BASE. The STATUS column is `CMP_EQUAL` on both, before and after.
* `canaries.sh` `ok=50 changed=2` (those same two dump-column cells, named in
  the transcript) and `ok=8 changed=0`; `ctcan2.sh` PASS ×2;
  `canaudit.sh canaries.sh ctcan2.sh` PASS, `audited=29 UNCOVERED=0
  FENCE-BREACH=0`.
* protected databases on this pass's own sweep: `SVSwitch 4842211c4030`,
  `YosysVerx 6ccda350c24a`, and `InterfaceModPort` / `BlackParrotComplex` /
  `YosysOldOr` all present with their md5s recorded per mode.

**The four protected CMP_EQUAL row-modes, both columns, explicitly:**

| row-mode | status | rowheads | census |
|---|---|---|---|
| `BuildUVMPkg` default | CMP_EQUAL | 0 lines / 0 heads | no one-sided cell |
| `BuildUVMPkg` testflags | CMP_EQUAL | 0 lines / 0 heads | no one-sided cell |
| `Earlgrey_0_1` default | CMP_EQUAL | 0 lines / 0 heads | 13 ONLY-GOLDEN / 13 ONLY-OURS |
| `Earlgrey_0_1` testflags | CMP_EQUAL | 0 lines / 0 heads | 13 ONLY-GOLDEN / 3022 ONLY-OURS |

The `Earlgrey_0_1` census cells are read on the PRISTINE binary at BASE and the
judge reads those rows EQUAL on that same binary: they are objects the official
Compare does not reach (extra materialized copies on our side, and an `other`-view
listing whose golden counterpart is folded). Nothing in this pass moves them —
nothing in this pass moves anything.

**Boundary.** With an empty production surface the boundary is exact rather than
sampled: **no committed arm of any earlier pass can move, because no binary
changed.** § `impFoldRhsMirrorsLhsTs201`, § `impUnsizedBasedLhsNoTs199` and its
paren-cast arm, § `impCopyStringConstSize`, § `modUnitImportParamsTwice196`,
§ `cloneStructMemberBareTdAlias207`, and the uvm82-91 / buvm3-15 / sd8-12 arms
are untouched by construction. This pass's own arms are additive and are the
first arms in the tree to pin the def-view `param_assign` Rhs FORM table.

---

## 8. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct210own.cpp` | the owner-finder. `--slots` / `--pkg` every listing holding a named `param_assign`, with a `ref_obj`'s ACTUAL kind and span; `--forms` the whole database as a readable table; `--key` the same as census keys; `--id` the parent chain of one UhdmId (the cmp log prints ids and never owners). |
| `ct210sub.cpp` | the sub-object and CELL compare. `cells` runs the OFFICIAL generated `Compare` on each index of a listing with a FRESH CompareContext, so `m_visited` cannot hide later cells. `ONLY=<LISTING>` restricts the walk. |
| `ct210inst.cpp` | the view-crossing reader: `--tsinst` every typespec's `Instance` back-pointer as a joinable key, `--pa-inst` which cells RECURSE, `--rhsof` the sharing map of one object, `--refto` who holds a typespec. |
| `cen210.sh` | the corpus form census over a `verify_golden` workdir. |
| `grid210.sh`, `grid210/` | the 8-arm golden grid, both views, real Surelog goldens. |
| `scrub210.sh` | the fence scrub (reads `FENCED=` out of `canaudit.sh`; never spells a fenced name). |
| `EDGE.r10uvm210.txt` | question (1): the head pair field by field, every listing, both modes, both writers. |
| `ROUTE.r10uvm210.txt` | question (1) continued: where the judge actually stops, the 7/45 cell census, and the crossing object. |
| `GRID.r10uvm210.txt` | question (2): the golden grid. |
| `DECODE.r10uvm210.txt` | questions (3)+(4): what the judge reads, what Surelog writes and where, with file:line. |
| `FORMS.SeqDriver.r10uvm210.txt`, `CENSUS.*.r10uvm210.txt` | question (5): the census, the head's row and both corpora. The uhdm2rtlil file is the SUMMARY rather than the 1358-line listing, for two reasons stated in its own header: every row scored zero on both sides, and one unfenced uhdm2rtlil row's NAME contains one of the four slang-fenced names as a SUBSTRING, which would raise a false `FENCE-BREACH` in the integration fence check's substring grep. Rows with any one-sided cell would still be printed in full; there are none. `cen210.sh` regenerates the listing on demand. |
| `GATES.r10uvm210.txt` | question (6): every gate, transcript. |
| `head_pris_SeqDriver.{default,testflags}.cmp` | the head, both modes. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged so this directory runs on its own. |

---

## 9. RESIDUES

* **R0 — THE NEXT HEAD: a DEF-VIEW CLASS-BODY TYPESPEC NAMES THE ELABORATED
  PACKAGE.** SeqDriver ×2, 50 cmp lines, one head, both modes. Golden mints a
  per-VIEW `unsupported_typespec` for a type-parameter-typed local in a package
  class method and gives the DEF-view copy `Instance` = the DEF package; we mint
  fewer and every one names the ELABORATED package. `typespec::Compare` reads
  `Instance`, so the judge follows the back-pointer into the wrong view of
  `uvm_pkg` and then compares golden's DEF `Param_assigns` against our
  ELABORATED ones — which is why the log names a `param_assign` Rhs that is in
  fact identical on both sides. Start from `ROUTE.r10uvm210.txt` §E and
  `ct210inst --tsinst`; the sixteen `REQ`/`RSP` keys are the visible population,
  and `grid210/g210_g_clsty.sv` is a four-line reproducer of the SHAPE (its own
  head is the `-nobuiltin` `AllPackages` size mismatch, so score it with
  `ct210inst --tsinst`, not with the arm's cmp verdict). **Decide on a golden
  grid over per-view class-body minting BEFORE any code** — this is the same
  split-mint question r10uvm207 answered for clone struct copies, one listing
  further out.
* **R1 — the `-elabuhdm` def-view `ref_obj` ACTUAL.** 13 grid cells, in the
  elab view of arms A (5), B (3), C (2), D (2) and G (1): with `-elabuhdm`, golden's def-view `ref_obj` for a bare
  parameter-reference default is bound to the referenced **`parameter`**; ours
  stays bound to that parameter's own `param_assign` Rhs object.
  `ElaboratorListener::enterPackage` seeds its `paramMap` from `Parameters()`
  where `enterModule_inst`/`enterInterface_inst` seed theirs from
  `Param_assigns` as name → `Rhs()`. **Corpus population zero** — no `-elabuhdm`
  corpus row carries a def-view `REF` cell at all. Arm E shows we already
  produce the `parameter` form where a `$unit`-scope import forces it, so the
  fix is a view predicate, not a new binding.
* **R2 — the QUALIFIED enum-constant default.** `parameter X = pkg::MEMBER;`
  Golden's declaring package keeps a `ref_obj` **named with the WRITTEN
  QUALIFIED name** (`p210f::F_RED`, fullname `p210f::p210f::F_RED`) and
  **UNBOUND** (`vpiActual` null), and every materialized import copy FOLDS it to
  a `constant`. We name it bare, bind it to the `enum_const`, and keep the
  `ref_obj` in the import copies too. Decoded:
  `CompileHelper::compileExpression`
  (`src/DesignCompile/CompileExpression.cpp:884-919`) tokenises a `pkg::NAME`
  primary, resolves the package through `Design::getPackage()` and mints a
  `constant` from `pack->getValue(NAME)` — which an enum member has and a bare
  name never reaches. Arms A (1 cell/view) and F (3 cells/view). **Corpus
  population zero on both corpora**, so it is recorded, not taken.
* **R3 — our shared Rhs constants.** Golden's six `UVM_SETINT` Rhs constants are
  six objects; ours is ONE object in six listings. `VpiParent` is read by no
  generated `Compare`, so the sharing itself is invisible — but it is what makes
  the crossing of R0 land on a `param_assign` instead of on the typespec that
  actually differs, and it is worth knowing when reading any future cmp log in
  this design.
* **R4 — `results/` has no default-mode uhdm2rtlil baseline.** Every row in
  `results/gate_uhdm2rtlil.csv` is `mode=testflags`, so RESUME §6's
  `ct8rows … u2r_def.csv` step can only be run against a rotated control, never
  against a committed file. The default arm's 679/50/2 histogram and
  `byteverify` are what stand in. Worth a committed default-mode baseline.
* **R5 — a `%s` fed a `std::string`.** `ct210sub` printed binary garbage for its
  first four runs because `printf("%s", face(x))` was passed the `std::string`
  itself. Recorded because it looked exactly like a cross-Serializer symbol-table
  problem and cost a wrong hypothesis: when a probe prints garbage, check the
  format call before the model.
