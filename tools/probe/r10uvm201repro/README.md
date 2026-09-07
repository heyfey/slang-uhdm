# r10uvm201 — § `impFoldRhsMirrorsLhsTs201` — **A MATERIALIZED IMPORT COPY'S FOLDED `param_assign` Rhs CONSTANT MIRRORS ITS OWN Lhs PARAMETER: WHEN THE Lhs CARRIES THE DECLARATION'S TYPESPEC, THE CONSTANT CARRIES A REF TO ONE TOO** — the SimpleUVM ×2 17-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here; the corpus censuses walk a sweep workdir that contains them, so
`scrub201.sh` redacts their names out of every artifact — reading the fence
list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `e5a04255` |
| pristine binary | md5 `abf4d2971987e060480a7dd3baba6e68`, built from this pass's OWN worktree at a clean `e5a04255` and frozen `chmod 555` before any sweep. It is **byte-identical to the main tree's binary at that commit**; its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for row (one informational dump-column cell excepted, R1). |
| patched binary | md5 `162d8642028fd69724c0bc621665c578`, frozen `chmod 555`. The patch applied to a **FRESH `e5a04255` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. (An ops note worth carrying: a COMMENT-ONLY edit to `ParamEmit.cpp` changes this md5, so "rebuilt byte-identical" has to be re-checked after any late prose fix — it was, and the committed text is exactly the text that compiled to `162d8642`.) |
| production surface | `src/ParamEmit.cpp` only — **one gated mint of five lines**, plus the decode. Nothing deleted, no object re-pointed, no name written, no existing gate touched. |
| probe surface | `tools/probe/r10uvm201repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 17 cmp lines, ONE head each → CLEARED**. The pristine head is `LHS` golden's `ref_typespec (work@top)` on the folded Rhs `constant` of `UVM_SETINT` (`uvm_object_globals.svh:217`), `RHS: <null>`. After the patch that object is gone and the next head is a **pre-existing, previously-MASKED** one: the elaborated `work@top`'s `vpiNet` VECTOR, golden 450 / ours 420 (§ 7, R0). Its cmp log is 1327654 lines only because a `module_inst`'s decompile is that big — the count is the head OBJECT's size, not a distance. |
| every other row's head | cmp log **BYTE-IDENTICAL** between the two binaries — SeqDriver ×2 33, Scoreboard/default 95, MiniAmiq ×2 33, BuildUVMPkg ×2 **0**, Earlgrey_0_1 833 / **0**, Rggen/default 0. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against this pass's own pristine sweeps. 1588 surelog rows, 731 + 731 uhdm2rtlil rows. `BuildUVMPkg` ×2, `Earlgrey_0_1/testflags` and `Rggen/default` stay **CMP_EQUAL** with both columns byte-identical, and so do the **ten** CMP_EQUAL row-modes a wider gate would have written into (§ 4). |
| byte movers | **6 / 956** surelog, and **all six PREDICTED BY NAME before the patched binary existed**, from PRISTINE databases alone: `{default,testflags} × {SimpleUVM, SeqDriver, MiniAmiq}`. `Scoreboard/default` did **not** flip this run — RESUME §9's ~50/50 coin landing the other way; its own order-blind diff is ADDED 0 / REMOVED 0. **0 / 1358** uhdm2rtlil, also predicted (that corpus's 67142 cells hold **not one** cell this gate can reach). |
| the attribution | 6 rows × **40 ADDED dump lines each = 240; REMOVED 0**. Every added line belongs to the four minted `ref_typespec → int_typespec` chains and to nothing else. At OBJECT level (`ct201obj`) on SimpleUVM/default: **exactly 8 objects created, in 2 kinds** — `ref_typespec` +4, `int_typespec` +4 — and **no other kind's count moves at all**. |
| the census (956 + 1358 databases, golden × ours) | surelog AGREE **48703 → 48727** (+24); TS-DIFF **2672 → 2624** (−48); ONLY-GOLDEN **1 → 1**, ONLY-OURS **158 → 158**, key sets BYTE-IDENTICAL. Cell counts identical on both sides before and after (48756 golden, 51481 ours). u2r **67142 cells, AGREE 67142, everything else 0, before AND after**. **TO-GOLDEN 24 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0** — 40 TS records cleared, **0 added**. |
| the predicate, on GOLDEN | `ct201cen --pred` on the SimpleUVM GOLDEN: `RHSGAP=0`. Ours, pristine: `RHSGAP=4`; patched: `RHSGAP=0`. `LHSGAP` is **24 on both sides, before and after** — a different family, carried in the payload as a guard. Corpus-wide, robustly totalled: surelog RHSGAP **46 → 22**, LHSGAP **519 → 519**; u2r RHSGAP **14 → 14**, LHSGAP **28 → 28**. The 22 that remain are 18 cells outside this population plus the 4 that GOLDEN HAS TOO (§ 4). |
| the grid (8 arms × 2 views = 16 arm-views, one REAL Surelog v1.86 golden each) | CALIB golden-vs-golden **AGREE 450, everything else 0**. PRISTINE TS-DIFF **76**, AGREE **378**; PATCHED TS-DIFF **8**, AGREE **412** (+34); ONLY-GOLDEN 34 → 34 and ONLY-OURS 30 → 30, key sets IDENTICAL; **0 nonzero rcs**. Of the 44 pristine TS rows, 36 cleared and **0 new ones appeared**; the 8 that remain are r10v199's **R0b**, on the package's own paren-cast-width parameter, identical on both binaries. |
| the WIDE boundary (5268 sources × 2 views × 2 binaries) | `LISTED=5268 PROCESSED=5268 PRODUCED_DBS=5083 MOVED_ARMS=10 RC_DIFFS=0`. Five are this pass's own POSITIVE CONTROL (and `g201_a_forms`, `g201_g_typed`, `g201_h_castw` are correctly ABSENT). **All 10 rebuilt with a REAL Surelog golden in BOTH views and scored: 20 views, TO-GOLDEN 40, AWAY-GOLDEN 0**, 0 unbuildable, 0 missing. |
| the FLOOR | uvm199's 7 arms, uvm197's 6, uvm196's 9, uvm195's 5, uvm194's 3, uvm193's 4, uvm192's 4, uvm191's 3, uvm190's 4, uvm189's 3, uvm188's 4, uvm187's 6, uvm186's 3, uvm185's 5, uvm184's 2, uvm170's 5, uvm82–91's 113, buvm3–15's 119, sd8–12's 347 — **652 arms, MOVED = 0**, verified BY NAME. § `parenCastWidthLhsKeepsTs199v`'s `v199_l_castw.sv` and its control `v199_m_ctl.sv` are both in `LISTED` and both **MOVED=0**. |
| gates | goldens **23/0** on both binaries, negative control **0/23**; canaries `ok=52` / `ok=8`, `changed=0` against this pass's own pristine; `ctcan2` PASS ×3; `canaudit` PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0`; all 10 protected databases SAME in both modes, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `e5a04255` worktree; it
came out **byte-identical** to the main tree's binary at that commit
(md5 `abf4d297…`). Every `cmds.txt` in every sweep names this pass's own frozen
binary, audited BY PATH — `find … -name cmds.txt -exec grep -h '^slang:'` over
both sweep workdirs yields exactly one distinct path, and it is the frozen one.

`rowheads.sh` on that sweep:

```
SeqDriver ×2 33 · SimpleUVM ×2 17 · Scoreboard/default 95 · MiniAmiq ×2 33
BuildUVMPkg ×2 0 · Earlgrey_0_1 833 / 0 · Rggen/default 0
```

The SimpleUVM head is **17 cmp lines, ONE head**, both modes
(`head_pris_SimpleUVM.{default,testflags}.cmp`, **byte-identical to each
other**) — the R0 r10uvm199 named:

```
LHS:
ref_typespec: (work@top), id:120084
|vpiParent:
\_constant: , id:120083, line:217:31, endln:217:38
|vpiFullName:work@top
|vpiActual:
\_int_typespec: , id:120085, line:217:1, endln:217:38
RHS: <null>
```

The count is the head OBJECT's decompile size, not a distance.

## 2. DECODING THE JUDGE — THE cmp LOG CANNOT NAME THE OWNER, AND THE OWNER-FINDER CAN

`RHS: <null>` with a full LHS is `BaseClass.h`'s SINGULAR `SafeCompare`
overload in its normal direction (RESUME §9): it names the **VALUE** that only
one side carries — golden's `constant::Typespec()` is a `ref_typespec`, ours is
null — and never prints the owner. `constant` derives from `expr`, and
`expr::Compare` (`~/git-repos/UHDM/build/generated/src/expr.cpp:95,100`) reads
`VpiSize` first and `Typespec` **second**, ahead of every `constant` field —
so a pair identical in decompile, value, size and const type still stops the
walk here.

That is a problem, because **SIX distinct objects in this database carry the
same name, span and value** for one parameter: the `Parameters`-listing entry
and the `param_assign` Lhs clone, times the two copies
§ `modUnitImportParamsTwice196` makes of a file-scope import item, plus the
elaborated and the package-side originals. `ct201own --slots` answers "which
one" by POSITION — every `param_assign` of that name with its LISTING named by
owner and INDEX, the Lhs parameter's typespec **and the Rhs's kind, span, const
type, size, value and typespec**.

On SimpleUVM/default, `UVM_SETINT` (full text in
`DECODE.slots.SimpleUVM.r10uvm201.txt`; `UVM_END_FUNCS` is identical in shape):

```
listing                                             GOLDEN Rhs-const ts      OURS Rhs-const ts
other   class_defn work@env  Param_assigns[35]/[80]  ref -> int_typespec      ref -> int_typespec
def     module_inst work@top Param_assigns[35].Lhs   ref#120084 -> int_typespec#120085   NO-TYPESPEC  <== THE HEAD
def     module_inst work@top Param_assigns[80].Lhs   ref#120523 -> int_typespec#120524   NO-TYPESPEC  <== its twin
elab    module_inst work@top Param_assigns[35]/[80]  ref -> int_typespec      ref -> int_typespec
defpkg  package uvm_pkg      Param_assigns[35]       Rhs is a ref_obj (not folded at all)  same
elabpkg package uvm_pkg      Param_assigns[35]       ref -> int_typespec      ref -> int_typespec
```

Three things fall out of that table, and they are the whole decode.

1. **Only the DEF-view module listing is wrong.** The `other` (class),
   `elab` and both package listings already carry the ref on both sides, and
   the def PACKAGE listing carries no folded constant at all — its Rhs is
   still a `ref_obj`, which is the `clone_tree` SOURCE and the reason the
   copy's constant exists in the first place.
2. **The Lhs half is already right.** In the def view our
   `Param_assigns[i].Lhs` parameter carries `ref -> int_typespec@217:1-217:38`
   exactly like golden's — § `impUnsizedBasedLhsNoTs199`'s object, converged
   one pass ago. Only its Rhs constant is bare. That asymmetry is the law's
   whole signature.
3. **Golden builds a DISTINCT `int_typespec` for the Rhs ref.** Golden's
   `Parameters[30]` names #119803, the `Param_assigns[35].Lhs` names #120088
   and the Rhs constant names #120085 — three objects, one span
   (`217:1-217:38`, the WHOLE DECLARATION LINE, while the constant itself
   spans only `217:31-217:38`, the reference text). Our emitter already has
   the code that builds that per-ref copy (§ 4); it had nothing to hang it on.

### THE PREDICATE, READ OFF GOLDEN — `ct201cen --pred`

`--pred` needs no golden, so it runs on any database; run on GOLDEN it
CALIBRATES the law:

```
                      cells   RHSGAP   LHSGAP
SimpleUVM GOLDEN        338        0       24
SimpleUVM OURS (pris)   338        4       24
```

`RHSGAP` = the Lhs parameter carries a typespec and its own folded Rhs constant
does not. **Golden has none.** `LHSGAP` (the reverse) is 24 on BOTH sides and
identical cell for cell — the unsized-based family whose Rhs constant carries a
ref with NO actual while the parameter carries nothing
(§ `implicitUnsizedBasedNoTs102` / § `unsizedBasedParamRhsSize106`); this pass
does not touch it, and carrying it in the payload makes it a GUARD.

Our four `RHSGAP` cells are `UVM_SETINT` and `UVM_END_FUNCS`, each ×2 copies,
all in `def|module_inst|work@top`, all `ct9/sz32`.

## 3. DECODING SURELOG — ONE TYPESPEC, TWO OWNERS, AND WHERE THE LINE ANCHOR IS MINTED

`CompileHelper::compileParameterDeclaration`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3788-3910`) reduces a
parameter's default and then, when the declaration has no written type, derives
one from the REDUCED CONSTANT:

```cpp
if (rhs && (rhs->UhdmType() == uhdmconstant)) {
  constant* c = (constant*)rhs;
  if (ts == nullptr) {
    switch (c->VpiConstType()) {
      case vpiRealConst:   ts = s.MakeReal_typespec();   ... param->Typespec()->Actual_typespec(ts); break;
      case vpiDecConst:    break;                        // 'd13 -> NO typespec at all
      case vpiIntConst:
      case vpiUIntConst:   its = s.MakeInt_typespec(); fC->populateCoreMembers(nodeId, nodeId, its);
                           ts = its; ... param->Typespec()->Actual_typespec(ts); break;
      case vpiHexConst:
      case vpiOctConst:
      case vpiBinaryConst: its = ...; if (c->VpiSize() != -1) { ...ranges...; ts = its; ... }  break;
      case vpiStringConst: ts = s.MakeString_typespec(); ... break;
    }
  }
  if (reduce == Reduce::Yes) adjustSize(ts, ...);
  int32_t size = c->VpiSize();
  if (ts) {                                   // <== OUTSIDE the switch, UNCONDITIONAL
    if (c->Typespec() == nullptr) { ref_typespec* tsRef = s.MakeRef_typespec();
                                    tsRef->VpiParent(c); c->Typespec(tsRef); }
    c->Typespec()->Actual_typespec(ts);
    ...
  }
  c->VpiSize(size);
}
```

Two facts decide this pass.

* **The parameter and its folded constant get the SAME `ts`.** The switch hangs
  it on the parameter; the block after the switch hangs it on the constant,
  with no further condition than `ts != nullptr`. So a typespec on the Lhs and
  a typespec on the Rhs constant are the same event. That is why golden's
  `RHSGAP` is 0 wherever the constant IS the declaration's own reduced Rhs, and
  it is why the mirror — not a restatement of the declaration-form predicate —
  is the right phrasing (§ 4).
* **The WHOLE-DECLARATION-LINE anchor is minted by
  `fC->populateCoreMembers(nodeId, nodeId, its)`**, where `nodeId` is the
  parameter DECLARATION node, not the value node. That is why golden's
  `int_typespec` spans `217:1-217:38` while the constant it types spans
  `217:31-217:38`. Our `makeParamTs` already anchors the same way — measured
  identical on the cells that were already right, and on the four repaired
  ones (§ 6).

`CompileHelper::importPackage` (`CompileHelper.cpp:238-273`) then materializes
the imported parameter by `clone_tree`-ing that already-compiled
`param_assign` — Rhs constant, its `ref_typespec` and the `int_typespec`
behind it included — which is why the copy carries exactly what the
declaration carries, in every importer and at any copy count.

### THE GOLDEN TABLE — measured on REAL Surelog goldens, not assumed (`grid201`)

Eight arms × two views (`-parse -d coveruhdm`, and again with `-elabuhdm`),
one real Surelog v1.86 golden each, CALIBRATED golden-vs-golden first
(`GRID.r10uvm201.txt`, `GOLDENTABLE.r10uvm201.txt`). The DEF-view materialized
copy's `param_assign` Rhs CONSTANT typespec, by DEFAULT FORM:

| declaration | golden | ours, pristine | ours, patched |
|---|---|---|---|
| `A_DEC = 13` (PLAIN DECIMAL) | `int_typespec` | `int_typespec` | `int_typespec` |
| `A_UHEX = 'hf000000` (UNSIZED BASED) | ref with **NO actual** | ref, no actual | unchanged |
| `A_SZ = 8'hab` (SIZED BASED) | `int_typespec` | `int_typespec` | `int_typespec` |
| `A_STR = "hello"` (STRING LITERAL) | `string_typespec` | `string_typespec` | `string_typespec` |
| `A_EXPR = 1 + 2` (EXPRESSION) | `int_typespec` | `int_typespec` | `int_typespec` |
| **`B_REFU = B_BASE`** (REFERENCE to an UNTYPED sibling) | **`int_typespec`** | **none** | **`int_typespec`** |
| **`B_REFT = B_TI`** (REFERENCE to a TYPED sibling) | **`int_typespec`** | **none** | **`int_typespec`** |
| `B_REFH = B_UHEX` (REFERENCE to an UNSIZED-BASED sibling) | ref, no actual, **size −1** | none, **size 32** | `int_typespec`, size 32 |
| `B_EXPR = B_BASE + 1` | `int_typespec` | `int_typespec` | `int_typespec` |
| `B_TI` (`parameter int`) | `int_typespec` | `int_typespec` | `int_typespec` |
| `G_RNG` / `G_SGN` / `G_INT` / `G_STR` / `G_TNIB` / `G_UDB` / `G_UNB` (arm G) | — | — | **byte-for-byte unchanged** |
| `H_W` / `H_X` (paren-cast width, arm H) | — | — | **byte-for-byte unchanged** |

**Two rows move and everything else stands.** `A_DEC`, `A_SZ`, `A_STR` and
`A_EXPR` are the controls that convict a blind widening: they already carried
the ref and they still do. `A_UHEX` is the control that proves this is not
"always mint": golden gives its constant a ref with NO ACTUAL and no
`int_typespec` at all, we already match, and the patched binary leaves it
exactly there.

`B_REFH` is the honest one. Its key does not even JOIN across the two sides —
golden's constant is `ct5/sz-1` (an unsized hex that Surelog never re-sizes)
and ours is `ct5/sz32` on **both** binaries — so it appears as
`ONLY-GOLDEN` / `ONLY-OURS`, whose counts are **34 / 30 before and 34 / 30
after, byte-identical key sets**. The cell is already divergent on the pristine
binary in a field `expr::Compare` reads FIRST (`VpiSize`, `expr.cpp:95`, before
`Typespec` at `:100`), so this pass's mint there is judge-unreachable, and
provably so rather than by luck. It is recorded as R2.

### THE OTHER ARMS — what each one TESTS rather than agrees with

| arm | what it separates | golden | pristine → patched |
|---|---|---|---|
| `g201_c_uvmshape` | the CORPUS SHAPE at 1/1000 the size: `uvm_object_globals.svh`'s `C_MACRO_EXTRAS → C_START_FUNCS → C_SET → C_SETINT` chain, next to a `parameter int` and a `parameter string` that must KEEP theirs | `int_typespec` on `C_SETINT` / `C_END_FUNCS` | none → `int_typespec`; **`C_KEEP_INT` and `C_KEEP_STR` byte-for-byte unchanged** |
| `g201_d_bodyimp` | a MODULE-BODY `import p::*` (ONE copy) instead of a file-scope one (TWO) | `int_typespec` | fixed at ONE copy too — **the copy COUNT does not change the verdict** |
| `g201_e_explicit` | `import p::E_REFU;` / `p::E_UNUSED;` — EXPLICIT items, one never referenced | `int_typespec` | fixed |
| `g201_f_kinds` | MODULE vs INTERFACE vs PROGRAM def listings out of ONE file-scope item | `int_typespec` in all three | fixed in all three. The `defif` arm is why `MiniAmiq` (an `interface_inst` def listing) is a mover |
| `g201_g_typed` | the NEGATIVE control: ranged, signed, `int`, `string`, typedef'd vector, decimal-based `'d13`, unbased-unsized `'0` | — | **0 cells differ, before AND after** |
| `g201_h_castw` | § `parenCastWidthLhsKeepsTs199v`'s shape, with a plain-arithmetic control beside it | — | **0 cells differ, before AND after**; its 8 remaining TS rows are r10v199's **R0b**, on the PACKAGE's own `H_W` parameter, identical on both binaries |

## 4. DECODING SLANG — ONE MISSING REF, AND A BINDER ALREADY WAITING FOR IT

`src/ParamEmit.cpp` already mints this ref on three paths:

* `:7814` — `if (wantTs)` on the LITERAL-init fold, for every literal form;
* `:14535` — § `modPkgRefIntTsRhs9`, for a MODULE'S OWN parameter defaulted
  from a package parameter reference, explicitly gated `!isImported`;
* `:14971` — the BINDER, which gives an imported Rhs ref its own FRESH per-ref
  `int_typespec` (`makeParamTs`, the paren-cast marks, the home instance),
  exactly the distinct object golden builds:

```cpp
if (rhsRt && !replFoldTs9) {
    if (!inPackage && isImported) {
        auto* itsR = makeParamTs(ps, typedParam);
        itsR->Instance(its->Instance());
        stampParenCastWidthTs(ps, up, itsR, nullptr);
        itsR->VpiParent(rhsRt);
        rhsRt->Actual_typespec(itsR);
    }
    else rhsRt->Actual_typespec(its);
}
```

The one form that reached NEITHER mint is the materialized import copy whose
default is a BARE REFERENCE to a sibling package parameter. `wantTs` IS true
for it (through `impCastFold9`, whose `elabFoldShape9()` accepts a
wildcard-imported bare pkg-param ref), so the PARAMETER got its typespec and
the def-view Lhs clone mirrored it — but no branch ever built a ref on the
folded constant, and `:14971` had nothing to bind. The fix is five lines that
set `rhsRt`, and the existing binder does the rest:

```cpp
if (!rhsRt && prtLhs9 && paRhs9 &&
    paRhs9->UhdmType() == UHDM::uhdmconstant &&
    !((UHDM::constant*)paRhs9)->Typespec()) {
    auto* rtI9 = s.MakeRef_typespec();
    rtI9->VpiFullName(prefix);
    rtI9->VpiParent(paRhs9);
    ((UHDM::constant*)paRhs9)->Typespec(rtI9);
    rhsRt = rtI9;
}
```

**Why `prtLhs9` and nothing wider — a MEASUREMENT, not a hope.** `prtLhs9` is
§ `impUnsizedBasedLhsNoTs199`'s object: the DEF-view materialized copy's own
Lhs parameter clone, carrying a typespec. "Golden never leaves a folded Rhs
constant bare under a typespec'd Lhs" is TRUE in that listing and **FALSE
outside it**, and two CMP_EQUAL corpus rows prove it. Both were read off the
PRISTINE databases with `ct201cen --pred`, before the patched binary existed:

| row | cell | golden | ours, pristine |
|---|---|---|---|
| `ParamFromPackage` ×2 | `other` view — the CHILD INSTANCE listing `u_aes_cipher_core/work@aes_cipher_core@13:4` of `aes_pkg::X` | Lhs `logic_typespec`, **Rhs constant NO-TYPESPEC** | already matches |
| `ParamTypespec` ×2 | `elab` view of `otp_ctrl_part_pkg::PartInvDefault`, whose def-view Rhs is an OPERATION that only the elaboration folds — to an UNLOCATED constant (span `0:0-0:0`) | Lhs `logic_typespec`, **Rhs constant NO-TYPESPEC** | already matches |

Neither constant is the `clone_tree` copy of the package's own reduced Rhs;
both are re-folds minted where the instance was elaborated, and Surelog's
`c->Typespec()` attach never runs for them. **A first cut of this patch gated
on `isImported` alone; the predictor found those two rows before it was ever
swept, and they are the reason the gate reads `prtLhs9`.**

The uhdm2rtlil corpus carries the same two shapes on three more rows —
`DivisionOfSize` (the `elab` unlocated re-fold) and
`ParameterFromPkgInNestedModule` / `ParameterFromPkgOnParameterPortList` (the
`other` child-instance listing) — so the wider gate would have taken **ten
CMP_EQUAL row-modes** away from golden, not two. All ten stay `CMP_EQUAL` with
both columns byte-identical (`GATES.r10uvm201.txt` § 7b), and the u2r census is
`AGREE 67142, everything else 0` before AND after.

Nothing downstream needed a change: `pendingParamTs` / `pendingDefParamTs`
(`:14790`, `:14803`) and the late `Actual_typespec` binding (`:14971`) were
already written against `rhsRt`, so a set `rhsRt` simply reaches them.

## 5. THE CENSUS AND THE MOVERS, PREDICTED BY NAME FROM PRISTINE DATABASES

`ct201cen --pred` needs no golden, so it ran over **every** database of the
PRISTINE sweeps, before the patched binary was built
(`PREDICTION.pristine.{surelog,u2r}.r10uvm201.txt`, robust totals from
`censum201.sh`):

```
surelog   956 databases   51481 param_assign cells   RHSGAP 46   LHSGAP 519
u2r      1358 databases   67142 param_assign cells   RHSGAP 14   LHSGAP  28
```

Of the 46 surelog `RHSGAP` cells, **28 carry a `vpiImported` tag** and 18 do
not (a different family — R3). Of the 28, **24 sit in the DEF-view
materialized copy** this law's gate reaches, and they are, by name and cell:

```
default/SimpleUVM   4 cells  def   module_inst  work@top                    × uvm_pkg
testflags/SimpleUVM 4 cells  (same)
default/SeqDriver   4 cells  def   module_inst  work@top_tb                 × {uvm_pkg, adpcm_pkg}
testflags/SeqDriver 4 cells  (same)
default/MiniAmiq    4 cells  defif interface_inst work@svaunit_vpi_interface × {uvm_pkg, svaunit_pkg}
testflags/MiniAmiq  4 cells  (same)
```

all of them `uvm_object_globals.svh:217` `UVM_SETINT = UVM_SET` and `:220`
`UVM_END_FUNCS = UVM_SETSTR`. The other 4 are `ParamTypespec` ×2 and
`ParamFromPackage` ×2 — the cells GOLDEN HAS TOO (§ 4), which the gate
deliberately leaves alone. **`byteverify SELFCHECK=1` on the patched sweep
then reported exactly 6 / 956, and they are exactly those six rows.**

The COMPARE-VISIBLE census (golden × ours, each row's golden read out of THAT
ROW'S OWN `cmds.txt`) puts every moved cell on the same six rows:

```
row / mode                cellsG cellsO   AGREE          TS-DIFF   ONLY-G  ONLY-O
default/SimpleUVM            338    338   334 ->  338     8 -> 0      0       0
testflags/SimpleUVM          338    338   334 ->  338     8 -> 0      0       0
default/SeqDriver            ...          the same shape, 8 -> 0
testflags/SeqDriver          ...
default/MiniAmiq             ...
testflags/MiniAmiq           ...
```

Robust totals (`censum201.sh`, R4): surelog `records=956 rows=956`
AGREE **48703 → 48727**, TS-DIFF **2672 → 2624**, ONLY-GOLDEN **1 → 1**,
ONLY-OURS **158 → 158**, `cellsG`/`cellsO` identical before and after. u2r
`records=1358 rows=1358` AGREE **67142 → 67142**, everything else 0.
Comparing the two censuses record for record: **40 TS records cleared, 0 TS
records added, ONLY-* key sets byte-identical.**
**TO-GOLDEN 24 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0.**

## 6. THE ATTRIBUTION

`attrib201.sh` dumps both databases, normalises the workdir path the dump
embeds, SORTS both and diffs — so a pure ORDER flip scores zero
(RESUME §9: `Scoreboard/default` is a ~50/50 coin per invocation).

```
default/SimpleUVM    ADDED=40 REMOVED=0    RHSGAP 4 -> 0   LHSGAP 24 -> 24
testflags/SimpleUVM  ADDED=40 REMOVED=0    RHSGAP 4 -> 0   LHSGAP 24 -> 24
default/SeqDriver    ADDED=40 REMOVED=0    RHSGAP 4 -> 0   LHSGAP 44 -> 44
testflags/SeqDriver  ADDED=40 REMOVED=0    RHSGAP 4 -> 0   LHSGAP 44 -> 44
default/MiniAmiq     ADDED=40 REMOVED=0    RHSGAP 4 -> 0   LHSGAP 72 -> 72
testflags/MiniAmiq   ADDED=40 REMOVED=0    RHSGAP 4 -> 0   LHSGAP 72 -> 72
default/Scoreboard   ADDED= 0 REMOVED=0    RHSGAP 0 -> 0   LHSGAP 16 -> 16   <== THE COIN, and it did not flip
-- TOTAL sorted-diff lines=240  ADDED-TOTAL=240  REMOVED-TOTAL=0
```

The 40 added lines of SimpleUVM/default, **in full** — every one belongs to the
four minted chains:

```
  4       |vpiTypespec:                            4   \_ref_typespec: (work@top)
  4   |vpiParent:                                  4       \_ref_typespec: (work@top)
  4         |vpiParent:                            2 (+2)  \_int_typespec: , line:217:1, endln:217:38
  4         |vpiFullName:work@top                  2 (+2)  \_int_typespec: , line:220:1, endln:220:41
  4         |vpiActual:                            2 (+2)  \_constant: , line:{217:31-217:38, 220:31-220:41}
```

A LINE count is a weak attribution, so the honest one is at the OBJECT level.
`ct201obj` counts every object by kind over `Serializer::AllObjects`; on
SimpleUVM/default:

```
kind                     golden     pris  patched  pris-gld  pat-gld
int_typespec               3022     3030     3034        +8      +12
ref_typespec              19364    18575    18579      -789     -785
-- no other kind's count moves.  objects created = 8.  totals 184965 -> 184973.
```

**Exactly 8 objects, and they are exactly the minted chain**: 4 cells ×
(1 `ref_typespec` + 1 `int_typespec`). In those cells our counts now EQUAL
golden's: golden builds three `int_typespec`s per def-view materialized cell
(the `Parameters` twin's, the `Param_assigns` Lhs clone's and the Rhs
constant's own), and so do we. The AGGREGATE `int_typespec` delta widens from
+8 to +12, and that is stated rather than dressed up: the aggregate is
dominated by a PRE-EXISTING overshoot from other families (r10uvm196's R3),
against which these four cells were a −4 compensation; removing the
compensation moves the aggregate without moving anything golden disagrees
with. The measurement that decides the direction is the compare-visible one —
the census (TO-GOLDEN 24, AWAY 0), the grid (36 TS rows cleared, 0 added), the
boundary (TO-GOLDEN 40, AWAY 0), and the head — and all four say the same
thing.

## 7. THE HEAD AFTER — AND R0

The head object is **gone**: our def-view `Param_assigns[i].Rhs` constant now
carries `ref_typespec (work@top) -> int_typespec @217:1-217:38`, exactly like
golden's, and `ct201cen --cen` on SimpleUVM reports `AGREE=338 TS-DIFF=0
ONLY-GOLDEN=0 ONLY-OURS=0 equal` — cell-for-cell equality on this face.

`uhdm-cmp` then stops at the NEXT failure, and it is one this law did not
create. Both modes, ONE head:

```
LHS golden  module_inst: work@top (work@top)   |vpiNet ×450
RHS ours    module_inst: work@top (work@top)   |vpiNet ×420
```

`BaseClass.h`'s VECTOR `SafeCompare` overload sets BOTH containers on a size
mismatch (RESUME §9), which is why the log is 1327654 lines: it is the head
OBJECT's decompile, not a distance. Counting the vectors on the two sides,
`vpiNet` is **the only one that differs**, and the 30 missing objects are 8
names:

```
4 × work@top.bld        4 × work@top.cs          4 × work@top.uvm_random_seed_table_lookup
4 × work@top.clp        4 × work@top.error_str   4 × work@top.val
4 × work@top.common     2 × work@top.top
```

**It was MASKED, not created.** The two databases' sorted dumps differ by
exactly the 40 lines above, all of them `typespec`/`constant` lines at
`217:*` and `220:*`; not one is a net, so the `vpiNet` counts are identical on
the pristine and the patched binary. `design::Compare` reaches `AllModules`
(the def listing, where the old head lived) before this elaborated one.

**R0 — THE ELABORATED `work@top` IS 30 `logic_net`s SHORT.** Golden's
`TopModules` `work@top` carries 450 nets, ours 420; the missing ones are eight
IMPLICIT nets Surelog materialises for names used in the testbench
(`bld`, `clp`, `common`, `cs`, `error_str`, `top`, `val`,
`uvm_random_seed_table_lookup`), each ×4 except `top` ×2. That is a NET
family, not a parameter one — the first head outside the
materialized-import-parameter cluster r10uvm196/197/199/201 have been working
through. `head_pat_SimpleUVM.{default,testflags}.summary.txt` carries the
vector table and the name list; the full 62 MB cmp log is reproducible in one
command and is deliberately not committed.

## 8. THE BOUNDARY AND THE FLOOR

```
LISTED=5268 PROCESSED=5268 PRODUCED_DBS=5083 MOVED_ARMS=10 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, PROCESSED is asserted
against LISTED). Five of this pass's eight `grid201/g201_*.sv` are the
POSITIVE CONTROL — they are all in the moved list, and without them a green
gate would prove nothing. The other three (`g201_a_forms`, `g201_g_typed`,
`g201_h_castw`) are the NEGATIVE controls and are correctly **absent**.
Several `--elabuhdm` runs segfault; they segfault **identically on both
binaries** (`RC_DIFFS=0`), and the counter records it rather than hiding it.

**All 10 moved arms were rebuilt with a REAL Surelog golden in BOTH views and
scored** (`bscore201.sh`, 20 views, 0 unbuildable, 0 missing, 0 nonzero rcs):

```
-- SCORED views=20 MISSING-ARMS=0 NODB-views=0 TO-GOLDEN=40 AWAY-GOLDEN=0
```

No view loses AGREE and no view's ONLY-GOLDEN or ONLY-OURS set grows. The five
non-grid movers:

| arm | what it is | verdict |
|---|---|---|
| `r10v199repro/grid_v199/v199_g_uvmshape.sv` | r10uvm199's verifier's own UVM-shape arm | **AGREE 45 → 47, TS-DIFF 4 → 0**, both views |
| `r10uvm67repro/a1_pkgparamts.sv` | package-param typespec arm | **AGREE 102 → 103, TS-DIFF 6 → 4**, both views |
| `r10uvm106repro/a1_bases.sv` | `parameter A_REF = A_HEX0;` — a reference to an UNSIZED-BASED sibling | AGREE, TS-DIFF and both one-sided sets **unchanged**; one cell's chain added (§ R2) |
| `r10v106repro/b05_ctx.sv` | `parameter W2 = W;` over `W = 'h8` — the same shape | likewise unchanged |
| `r10v93repro/v5_more93.sv` | `localparam v5_b = v5_a;` over a size-cast sibling | likewise unchanged |

The last three move BYTES without moving the census, and that is R2, stated
rather than hidden: the affected cell's key does not even JOIN across the two
sides, because our folded constant's `VpiSize` already differs from golden's
on **both** binaries, so the cell is already unequal in a field
`expr::Compare` reads BEFORE `Typespec` (`expr.cpp:95` vs `:100`). Their
`ONLY-GOLDEN` / `ONLY-OURS` counts are identical before and after. Each adds
exactly one `ref_typespec` + one `int_typespec`, nothing else
(order-blind diff: ADDED 11, REMOVED 0 — the single "removed" line is the
dump's own output-path header).

**THE FLOOR IS UNTOUCHED**, verified BY NAME in the boundary's own `LISTED`
and `MOVERS` files rather than assumed:

```
uvm199 (7 arms)  uvm197 (6)  uvm196 (9)  uvm195 (5)  uvm194 (3)  uvm193 (4)
uvm192 (4)  uvm191 (3)  uvm190 (4)  uvm189 (3)  uvm188 (4)  uvm187 (6)
uvm186 (3)  uvm185 (5)  uvm184 (2)  uvm170 (5)  uvm82-91 (113)
buvm3-15 (119)  sd8-12 (347)          652 arms, MOVED = 0
```

§ `impUnsizedBasedLhsNoTs199`'s arms, § `impCopyStringConstSize`'s,
§ `modUnitImportParamsTwice196`'s, r10uvm188's render arms and r10uvm187's
deferral arms are all in that list and all still. § `parenCastWidthLhsKeepsTs199v`'s
own `v199_l_castw.sv` and its isolating control `v199_m_ctl.sv` are present in
`LISTED` and **MOVED=0**.

## 9. RESIDUES, ranked

* **R0 — the elaborated `work@top` is 30 `logic_net`s short**, § 7. The
  current head, both SimpleUVM modes, one field (`vpiNet` vector size, 450 vs
  420), eight implicit-net names. A NET family — the first head this cluster's
  four passes leave that is not a materialized-import parameter.
* **R1 — the `Earlgrey_0_1/testflags` dump-column cell in the COMMITTED
  baseline.** This pass's PRISTINE binary already reports
  `Earlgrey_0_1,testflags,CMP_EQUAL,,,` where `results/golden_surelog.csv`
  records `…,CMP_EQUAL,,,differ` — the STATUS agrees, only the informational
  dump column differs, and it differs on the pristine binary too (r10uvm197
  and r10uvm199 recorded the same cell). It is not this pass's, nothing was
  promoted, and `results/*.csv` were read only. The master should decide
  whether to refresh that one informational cell.
* **R2 — the REFERENCE-TO-AN-UNSIZED-BASED-SIBLING size residue.**
  `parameter W = 'h8; parameter W2 = W;` — golden's folded Rhs constant for
  `W2` keeps `VpiConstType 5` with `VpiSize -1` and a `ref_typespec` with NO
  actual, and its parameter carries no typespec; ours carries `VpiSize 32`,
  an `int_typespec` on the parameter, and now one on the constant as well.
  Wrong on the pristine binary already, in a field `expr::Compare` reads
  first, so this pass's mint there is judge-unreachable. Reproducers:
  `grid201/g201_b_refs.sv`'s `B_REFH` (the census's whole ONLY-GOLDEN 34 /
  ONLY-OURS 30, identical on both binaries), `r10uvm106repro/a1_bases.sv`
  `A_REF`, `r10v106repro/b05_ctx.sv` `W2`, `r10v93repro/v5_more93.sv`
  `v5_b`. It belongs to § `unsizedBasedParamRhsSize106`, not here. **No corpus
  row carries it through this pass's gate** — the 6 byte movers are fully
  attributed and none of them is this shape.
* **R3 — the 18 NON-IMPORTED `RHSGAP` cells.** `ct201cen --pred` finds them on
  10 surelog rows (`EnumConstElab`, `FuncNoArgs`, `NoParamSubs`,
  `NoReducTypespec`, `PackedArrayHighConn`, `ParamNoSubst`, `ParamOverloading`,
  `PAssignType`, `PatternAssignLogic`, `TypespecExpr`), all `logic_typespec`
  or `bit_typespec`, mostly in the `elab` and `other` views, and all on rows
  that are already `CMP_EQUAL` or whose head is elsewhere. This pass's gate
  does not reach them and this pass does not claim them. Whether golden has
  the ref on those cells is unmeasured here and is the first thing a follow-up
  should run `ct201cen --pred` on the GOLDEN side to find out — the two
  imported cells of the same shape (§ 4) turned out to be cells GOLDEN LEAVES
  BARE.
* **R4 — the `xargs -P` interleave trap, carried forward from r10uvm199 and
  paid for again.** `cen201.sh` runs its rows under `xargs -P`, so two rows'
  lines can INTERLEAVE and a `PREDSUM`/`CENSUM` record can end up glued to
  another row's line. It happened once here: the pristine surelog PREDICTION
  file's own `-- TOTALS` line read `PRED-CELLS=51473` where the truth is
  **51481**, and a `RC` line ended up inside a `PRED` line. `censum201.sh`
  totals with `grep -o` over the whole record and ASSERTS record-count ==
  row-count; it flagged that file (`records=956 rows=955`). **Every census and
  prediction number in this README comes from `censum201.sh`; the raw files'
  own `-- TOTALS` lines must not be quoted.** This pass extended
  `censum201.sh` to handle the `--pred` files too, which is how the glue was
  caught at all.
* **R5 — r10v199's R0b is still open and this pass's grid arm H measures it.**
  § `implicitUnsizedBasedNoTs102` does not know about paren-cast-width
  parameters, so the PACKAGE's own `H_W` carries no `int_typespec` where
  golden gives it one. It is the entire remaining TS-DIFF of the grid (8 of
  the 16 arm-views' 8 cells), identical on both binaries, and it is r10v199's
  residue, not this pass's. The fix belongs at `ParamEmit.cpp:4732`.

## 10. THE FILES

| file | what it is |
|---|---|
| `ct201own.cpp` | the OWNER-FINDER for the Rhs half. `--slots <db> <name>` prints every `param_assign` of that name with its LISTING named by owner and INDEX, the Lhs parameter's id/span/`vpiImported`/typespec AND the Rhs's kind, id, span, const type, size, value and TYPESPEC; `--pkg` restricts it to package owners (the `clone_tree` source); `--anchor` prints the three spans side by side, which is how the whole-declaration-line anchor is told from a value-site one. |
| `ct201cen.cpp` | the CENSUS / MOVER PREDICTOR / GOLDEN-TABLE reader. `--pred <db>` needs no golden and classifies every `param_assign` cell as `RHSGAP` (Lhs typed, Rhs constant bare) or `LHSGAP` (the reverse); `--list <db>` prints every cell with its payload so a golden table is READ OFF rather than inferred; `--cen <golden> <ours>` is the compare-visible multiset join, keyed on view + owner face + param + `vpiImported` + DEFAULT FORM, payload the PAIR `<Rhs const ts>/<Lhs param ts>` so r10uvm199's converged parameter half is a guard. Golden-vs-golden calibrates to `AGREE=cells, TS-DIFF 0, ONLY-* 0`. |
| `ct201obj.cpp` | the whole-database OBJECT-KIND counter, for the object-level attribution. |
| `cen201.sh` | runs either mode over a whole `verify_golden` workdir; each row's golden is read out of THAT ROW'S OWN `cmds.txt`, never guessed from a test name. |
| `censum201.sh` | the ROBUST totaller (r10uvm199's R4, paid for again here — see R4) — the only number to quote. |
| `grid201/` + `grid201.sh` | eight arms × two views × one real Surelog golden each, CALIBRATED golden-vs-golden and scored on both binaries. |
| `bound201.sh` / `bscore201.sh` | the wide boundary and the golden scoring of every arm it moved. |
| `attrib201.sh` | the order-blind sorted-dump attribution plus the RHSGAP/LHSGAP cell counts. |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the gate battery (copies, unmodified). |
| `scrub201.sh` | redacts the four fenced test names out of the evidence files, reading the list out of `canaudit.sh`. |
| `GATES.…txt` | every gate, with the numbers. |
| `DECODE.slots.SimpleUVM.…txt` | § 2's slot table in full, golden × pristine, for the two moved parameters and the four that must not move. |
| `GOLDENTABLE.…txt`, `GRID.…txt` | § 3's golden table and the raw grid. |
| `CENSUS.*`, `PREDICTION.*`, `OBJECTS.*`, `BOUNDARY*.*`, `ATTRIBUTION.*` | the raw evidence behind § 5, § 6 and § 8. |
| `head_{pris,pat}_SimpleUVM.{default,testflags}.cmp` | the official `uhdm-cmp` head, before and after. |

## 11. REPRODUCING

```bash
git worktree add /tmp/wt e5a04255 && cd /tmp/wt
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2
cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris        # md5 abf4d297…
git apply /tmp/r10uvm201.patch && cmake --build build -j 2
cp build/slang-uhdm /tmp/pat && chmod 555 /tmp/pat          # md5 162d8642…

cd tools/probe/r10uvm201repro
for t in cen own obj; do g++ -O2 -std=c++17 ct201$t.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct201$t; done
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=/tmp/ct201cen ./grid201.sh "$PWD/grid201" /tmp/gs /tmp/GRID.txt
```
