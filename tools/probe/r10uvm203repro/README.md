# r10uvm203 — § `oobCtorLocalsRideTheImport203` — **WHAT A MODULE MATERIALISES FROM AN IMPORTED PACKAGE IS THE PACKAGE'S OWN VARIABLE LISTING — HOISTED OUT-OF-BODY CONSTRUCTOR LOCALS AND DYNAMIC CONTAINERS INCLUDED — NOT A RE-WALK OF ITS MEMBERS** — the SimpleUVM ×2 1327654-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here and are not spelled in any artifact; `canaudit.sh`'s own `FENCE-BREACH=0`
is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `8a67584d` |
| pristine binary | md5 `c2343ac3c6d0eb267e7e9724d1766e74`, built from this pass's OWN worktree at a clean `8a67584d` and frozen `chmod 555` before any sweep. **Byte-identical to the main tree's binary at that commit.** Its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for row, one informational dump-column cell excepted (R5). |
| patched binary | md5 `b801e95a2dd8fc85be5d8f28e21a090c`, frozen `chmod 555`. The patch applied to a **FRESH `8a67584d` worktree** (`cmake -DCMAKE_BUILD_TYPE=Release`) and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. A COMMENT-ONLY edit to any of the six files changes this md5, so the committed text is exactly the text that compiled to `b801e95a`. |
| production surface | `src/EmitHelpers.h`, `src/ParamEmit.cpp`, `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`, `src/ExprEmit.cpp`, `include/UhdmExporter.h` — ONE listing rebuilt, one suppression narrowed, one mint made a last resort. Nothing deleted, no object re-pointed, no name written that golden does not write. |
| probe surface | `tools/probe/r10uvm203repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 1327654 cmp lines, ONE head each → CLEARED.** The pristine head is `module_inst work@top` `id:197492` — `design->AllModules[1]`, the **DEF** view (not the elaborated one; r10uvm201's R0 named it "elaborated" and that framing is corrected in § 1) — on its `vpiNet` VECTOR, golden **225** objects / ours **210**. After the patch that vector is 225 on both sides and every element agrees. |
| the correction to R0's arithmetic | r10uvm201's R0 read "450 / 420, eight names at multiplicity four (two for one of them)" out of the cmp LOG. `uhdm-dump` prints each `vpiNet` entry **twice**, so the OBJECT counts are **225 / 210** and the missing set is **fifteen** nets: seven names at multiplicity 2 and `top` at 2-against-our-1. `grep -c '^|vpiNet:'` per side reads 450/420; `Nets()->size()` reads 225/210 (`VECTORS.SimpleUVM.r10uvm203.txt`). |
| what the fifteen ARE | **not implicit-net mints.** Every one carries a real typespec and the span of a real DECLARATION: `bld` `common` (`uvm_component.svh:1746/1747`, a nested `begin`'s locals), `error_str` `top` `cs` (`:1729-1731`, the function-body locals) — all of `function uvm_component::new`; `clp` `val` (`uvm_phase.svh:801/802`, inside `function uvm_phase::new`'s `begin`); and `uvm_random_seed_table_lookup` (`uvm_misc.svh:328`), a package-scope ASSOCIATIVE ARRAY. They are the eight entries our `uvm_pkg` **already lists correctly** and the module hoist was not copying. |
| the head after | the **`design` object itself**, on `design->Typespecs()`, golden 123 / ours 89 — a gap the **PRISTINE** binary has too (89 there as well, `VECTORS.SimpleUVM.r10uvm203.txt`), MASKED until now because `design::Compare` reaches `AllModules` (`design.cpp:302`) before `Typespecs` (`:303`). It was **not created here.** Its 4177864-line log is the DESIGN's decompile size, not a distance. |
| every other row's head | **unchanged, both binaries**: SeqDriver ×2 **50**, Scoreboard/default **95**, MiniAmiq ×2 **50**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 **386** / **0**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against this pass's own pristine sweeps: **0 / 1588** surelog rows, **0 / 731** u2r testflags, **0 / 731** u2r default. The four CMP_EQUAL row-modes the brief protects — `BuildUVMPkg/default`, `BuildUVMPkg/testflags`, `Earlgrey_0_1/testflags`, and (scored with them) `Rggen/default` — stay CMP_EQUAL with **both columns byte-identical**, and so does every other CMP_EQUAL row-mode. |
| byte movers | **4 / 956** surelog, and the moved set EQUALS the predicted set: all four were **PREDICTED BY NAME before the patched binary existed**, from PRISTINE databases alone (`ct203pred`, `PREDICTION.pristine.surelog.r10uvm203.txt` — 1573 dirs visited, `FIRING=4`): `{default,testflags} × {SimpleUVM, SeqDriver}`. `Scoreboard/default` did not flip on this run; on an earlier run of the same two binaries it did, and RESUME §9's ~50/50 coin is what that is — its order-blind diff was **ADDED 0 / REMOVED 0** and the predictor reads `FIRES=0` on its pristine database. **0 / 1358** uhdm2rtlil, also predicted (`FIRING=0` over 1462 visited dirs). |
| the attribution | SimpleUVM **ADDED 600 / REMOVED 3** per mode; SeqDriver **ADDED 302 / REMOVED 0** per mode. The three removed lines per SimpleUVM database are the ONE `logic_net (work@top.top) 67:18-67:21 vpiNetType:1` the `$dumpvars` scope-name arm no longer mints — the only removal anywhere, and the one golden also does not make. |
| the census (net + variable listings of every scope, golden × ours) | SimpleUVM ×2: AGREE **638 → 688**, TS-DIFF **4 → 0**, ONLY-GOLDEN **46 → 0**, ONLY-OURS **0 → 0** — **cell-for-cell equality on this whole face**. SeqDriver ×2: AGREE **654 → 670**, ONLY-GOLDEN **98 → 66**, ONLY-OURS **0 → 0**. **MOVED-WRONG 0 / AWAY-GOLDEN 0** on all four, scored key by key (`dir203.py`). |
| the grid (6 arms × 2 views = 12 arm-views, one REAL Surelog golden each) | CALIB golden-vs-golden **AGREE 756, everything else 0**. PRISTINE AGREE **442**, TS-DIFF **38**, ONLY-GOLDEN **276**; PATCHED AGREE **672** (+230), TS-DIFF **16**, ONLY-GOLDEN **68**; ONLY-OURS **76 → 76**, unchanged — **not one new one-sided cell**. **0 nonzero rcs.** |
| the WIDE boundary (5305 sources × 2 views × 2 binaries) | `LISTED=5305 PROCESSED=5305 PRODUCED_DBS=5120 MOVED_ARMS=84 RC_DIFFS=0`. Five of this pass's six grid arms are in the moved list — the POSITIVE CONTROL — and `g203_e_ctl` is correctly **ABSENT**. **All 84 were rebuilt with a REAL Surelog golden in BOTH views and scored: `SCORED views=167 MISSING-ARMS=0 NODB-views=1 TO-GOLDEN=2422 AWAY-GOLDEN=0`.** |
| the FLOOR | § `impFoldRhsMirrorsLhsTs201`'s arms (`r10uvm201repro`), § `impUnsizedBasedLhsNoTs199`'s and the paren-cast arm (`r10uvm199repro`, `r10v199repro`), § `impCopyStringConstSize`'s (`r10uvm197repro`), § `modUnitImportParamsTwice196`'s (`r10uvm196repro`), and **buvm3–15** are **ALL MOVED=0**, verified by name against `BOUNDARY_MOVERS.r10uvm203.txt`. |
| gates | goldens **23/0** on both binaries, negative control **0/23**; every `cmds.txt` in every sweep names exactly one binary and it is the frozen one for that arm; canaries `ok=52 changed=0` against this pass's own pristine and `ok=8 changed=0` on u2r; `ctcan2` PASS ×3; `canaudit` PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0` (after `scrub203.sh` redacted the fenced names out of the two PREDICTION artifacts, which the predictor writes because it walks a whole sweep workdir); all ten protected databases **SAME** in both modes, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. Full battery verbatim in `GATES.r10uvm203.txt`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `8a67584d` worktree; it
came out **byte-identical** to the main tree's binary at that commit
(md5 `c2343ac3…`). Every `cmds.txt` in every sweep names one of this pass's two
frozen binaries, audited BY PATH — `find … -name cmds.txt -exec grep -h '^slang:'`
over each sweep workdir yields exactly one distinct path, and it is the frozen
one for that arm.

`rowheads.sh` on the pristine sweep:

```
SeqDriver ×2 50 · SimpleUVM ×2 1327654 · Scoreboard/default 95 · MiniAmiq ×2 50
BuildUVMPkg ×2 0 · Earlgrey_0_1 386 / 0 · Rggen/default 0
```

The SimpleUVM head is **ONE head**, both modes:

```
LHS:
decompile:
module_inst: work@top (work@top), id:197492, file:.../SimpleUVM/testbench.sv, line:44:1, endln:71:10
  … |vpiNet ×450 …
RHS:
module_inst: work@top (work@top), …
  … |vpiNet ×420 …
```

`id:197492` is `design->AllModules[1]` — **the DEF-view module**, not the
elaborated one. The elaborated `work@top` (`id:197854`, `TopModules[0]`) carries
`Nets()` **0** on BOTH sides; its listing is `Variables()`, golden 68 / ours 52.
r10uvm201's R0 called the head "the elaborated `work@top`"; it is the def one,
and the correction matters because the two views take different code paths and
only one of them mints nets.

`BaseClass.h`'s VECTOR `SafeCompare` (`:206-225`) sets **both containers** on a
size mismatch, which is why the log is 1327654 lines: it is the head OBJECT's
decompile, not a distance.

**The 450/420 in that log is a DUMP artifact.** `uhdm-dump` emits `|vpiNet:` once
per entry and the module's decompile is printed twice inside one cmp record, so
`grep -c '^|vpiNet:'` reads 450 on the golden side and 420 on ours while
`Nets()->size()` reads **225** and **210** (`ct203net`). The shortfall is
**fifteen** objects, not thirty, and the multiplicities are 2, not 4.

## 2. QUESTION 1 — THE FIFTEEN, BY NAME, WITH THEIR FIELDS AND REFERRERS

`ct203net --refs` on golden. Every one hangs at **module level**, `vpiParent` the
def-view `module_inst work@top`, `vpiNetType` **0** (unset), and every one
carries a REAL typespec at a REAL declaration span:

```
name                          span (uvm-1.2 src)                    typespec                     referrers
bld                           base/uvm_component.svh 1746:15-1746:18 class_typespec uvm_phase     0
common                        base/uvm_component.svh 1747:16-1747:22 class_typespec uvm_domain    0
error_str                     base/uvm_component.svh 1729:10-1729:19 string_typespec              0
top                           base/uvm_component.svh 1730:12-1730:15 class_typespec uvm_root      1   <== see below
cs                            base/uvm_component.svh 1731:21-1731:23 class_typespec uvm_coreservice_t 0
clp                           base/uvm_phase.svh      801:27-801:30  class_typespec uvm_cmdline_processor 0
val                           base/uvm_phase.svh      802:12-802:15  string_typespec              0
uvm_random_seed_table_lookup  base/uvm_misc.svh       328:14-328:42  class_typespec uvm_seed_map  0
```

each at **multiplicity 2**, and our listing carries **none of them** except one
`top` — and that one is a different object (below).

**The use sites decide the multiplicity, and they are IMPORT COPIES, not uses.**
`testbench.sv` writes `import uvm_pkg::*;` at FILE scope, which
§ `collectMaterializedPkgs` (r10apb2, Surelog-measured) has copying the package's
whole listing **TWICE**; a module-scope import would add one more. So the
multiplicity is the IMPORT's, not the reference's: golden's `work@top` net
listing is
**[the package's 33-entry listing] × 2 → `clk`, `environment` → 157 implicit wires**
(225 = 66 + 2 + 157), and ours was
**[25 of those 33] × 2 → `clk`, `environment` → 158 implicit wires** (210).
Not one of the eight names is referenced anywhere in `design.sv` or
`testbench.sv`. They ride because the IMPORT rides them.

**The one referrer is the whole second half of the law.** Golden's FIRST `top`
net carries exactly one referrer:

```
REF ref_obj|top|67:18-67:21  parent=sys_func_call|$dumpvars|67:5-67:22
```

`$dumpvars(0, top)` in `testbench.sv:67`. Golden binds that reference to the
materialized net and mints **nothing**. Ours could not bind it (there was no net
of that name) and minted an implicit wire — `logic_net (work@top.top)
67:18-67:21`, `vpiNetType 1`, no typespec — which is why the name census showed
`top` present on our side at multiplicity 1: a DIFFERENT object wearing the same
name.

**Where they hang, and where they do NOT.** The 157 `vpiNetType 1` entries after
`clk`/`environment` are the implicit-wire block § `oobRefVarLocalHoistNet107` /
§ `pkgFreeSubRefVarHoistNet117` / § `newArrayArgHoistNet130` /
§ `assocIdxNameHoistNet135` already model; their multiset is **identical on both
sides before and after** this pass. Their ORDER differs, and that is
judge-invisible: `logic_net::Compare` (`logic_net.cpp`) reads `Left_expr`,
`Right_expr`, `Ranges`; `expr::Compare` (`expr.cpp:90-100`) reads `VpiDecompile`,
`VpiSize` and `Typespec`; **no ancestor reads `VpiName` for a net**, so a
permutation of typespec-less, netType-1 wires compares EQUAL. That is measured,
not assumed: with the sizes matched the judge walks straight past `AllModules`
and stops at `design->Typespecs` (§ 6).

## 3. QUESTION 2 — DECODING SURELOG

**The fifteen are the IMPORT's copy of the package's variable listing.**
`CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:127`), the
Variables arm at `:171-181`:

```cpp
    // Variables
    auto& variableSet = def->getVariables();
    for (auto& var : variableSet) {
      if (!object_name.empty()) { if (var.first != object_name) continue; }
      scope->addVariable(var.second);
      Value* val = def->getValue(var.first);
      if (val) scope->setValue(var.first, m_exprBuilder.clone(val), m_exprBuilder);
    }
```

It copies the PACKAGE COMPONENT's variable registry into the importing scope
wholesale — and that registry is where Surelog leaves the body locals of an
OUT-OF-BODY CONSTRUCTOR (the fact § `collectOobCtorLocals` already decoded for
the package's own listing: `uvm_phase::new`'s `clp`/`val`, `uvm_root::new`'s
`rh`, `uvm_component::new`'s `error_str`/`top`/`cs` plus `bld`/`common` from a
nested `begin`, and a non-`new` out-of-body body hoists nothing). The same
function forwards the unbound-reference list at `:192-197`
(`scope->needLateBinding(var)`), which is § 117's own citation — the two halves
ride the same import.

The **ORDER** is not that registry's: `DesignComponent::VariableMap` is a
`std::map<std::string, …>` (`include/Surelog/Design/DesignComponent.h:97`), i.e.
alphabetical, while golden's listing is **flattened-source order**. It is the
Signal/elaboration pass that orders it, and the observable law is what the grid
measures: grid arm A's package declares `pa_own0`, `pa_own1`, five constructor
locals, `pa_own2`, and golden's module block reads them in exactly that source
order, three times over, **not** alphabetically (§ 5).

**The implicit-wire mint is a DIFFERENT mechanism, and it is a LAST RESORT.**
`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3294`) walks the
reference's own `VpiParent` chain and only when every arm has failed reaches the
mint at `:3982-4004`:

```cpp
    if (!ref->Actual_group()) {
      if (mod) { if (auto elem = mod->getDesignElement()) {
        if (elem->m_defaultNetType == VObjectType::slNoType) { …ELAB_ILLEGAL_IMPLICIT_NET… }
        else if (m && (m->UhdmType() == uhdmmodule_inst || …)) {
          logic_net* net = s.MakeLogic_net();
          net->VpiName(name); net->VpiParent(m);
          net->VpiNetType(UhdmWriter::getVpiNetType(elem->m_defaultNetType));
          … ref->Actual_group(net); inst->Nets()->push_back(net); } } } }
```

`NetlistElaboration::bind_net_` (`src/DesignCompile/NetlistElaboration.cpp:2973`
and `:3086`, mint at `:3065-3078`) is the other minter, for the port-connection
and continuous-assign contexts. Both are gated on the name having failed to
resolve — and a name the module's net listing already carries **resolves**.
That is why golden's `$dumpvars(0, top)` binds the materialized `top` and mints
nothing, and it is the shape grid arm D isolates against a control.

## 4. QUESTION 3 — DECODING SLANG, AND WHERE OUR EMISSION DROPPED THEM

slang declines nothing here; **our hoist was reading the wrong list.**
`collectImportedPkgVars` (`src/EmitHelpers.h`) walked `pkg->members()` — the
package symbol's own members — and dropped six type kinds:

```cpp
    for (auto& [pkg, copies] : collectMaterializedPkgs(body))
        for (int i = 0; i < copies; i++)
            for (auto& pm : pkg->members())
                if (pm.kind == SymbolKind::Variable && modelled(pm))
                    out.push_back(&pm.as<VariableSymbol>());
```

Two consequences, and they are exactly the fifteen:

1. **The seven out-of-body constructor locals are not package members at all** —
   they are locals of a `SubroutineSymbol` that hangs off the class. Our own
   PACKAGE listing already merges them in (`emitPackage`,
   `src/ParamEmit.cpp:~22900`, `collectOobCtorLocals` + the `includeExpandedKey`
   flush), so `uvm_pkg`'s `Variables()` is **33 entries, byte-identical to
   golden's, in the same order, on both binaries**. Only the module's copy was
   short.
2. **`uvm_random_seed_table_lookup` is an `AssociativeArrayType`**, which
   `modelled()` rejected and which `emitPackageVar` also refused for the module
   copy in as many words: *"…in the PACKAGE's own listing only; the copy an
   importing MODULE materialises is unmeasured, so it keeps dropping."* It is
   measured now.

A third, smaller drop showed up the moment the first two were fixed and it is a
NAMING one: § `localClassTsUnnamed15` unnames a class handle declared inside a
subroutine when the class's home design component is the same as the
declaration's — right for `bld` **at its package-scope declaration**, wrong for
the module's COPY, because Surelog re-compiles the written type **in the
importing module** (which is why the copy's typespec carries no `vpiInstance`
at all — `emitPackageVar`'s `stampTsInstance`). Golden's five class-handle
copies are NAMED (`uvm_cmdline_processor`, `uvm_root`, `uvm_coreservice_t`,
`uvm_phase`, `uvm_domain`) while the package's own are not. Without that
correction the head simply moved down one level, to
`class_typespec (uvm_cmdline_processor)` against our unnamed one — a 22-line
head this pass measured and then cleared.

## 5. THE LAW, AS ONE GATED CHANGE

> **§ `oobCtorLocalsRideTheImport203`.** A module's MATERIALIZED-IMPORT listing
> is a COPY OF THE HOME PACKAGE'S OWN VARIABLE LISTING — the same
> include-expanded, source-ordered merge of the package's own data declarations
> with the OUT-OF-BODY CONSTRUCTOR body locals Surelog leaves behind in it, with
> the three DYNAMIC containers included — repeated once per import copy.
> The class handle among them is typed by a class_typespec that carries the
> class NAME, because the copy's home design component is the IMPORTING MODULE.
> And the implicit-wire mint for a scope name handed to a system call is a LAST
> RESORT: a net the module already lists resolves the reference instead.
>
> ONE EXCEPTION, measured on a golden of its own (grid arm F): a container
> whose ELEMENT is a PACKED STRUCT rides into the module's DEF view and NOT
> into its ELABORATED one, while a packed-union, int-typedef, class-typedef and
> bare-class element ride into both.

Six edits, each a term of that sentence:

| file | edit |
|---|---|
| `src/EmitHelpers.h` | `collectOobCtorLocals`'s walk moved here verbatim as the free `collectOobCtorLocalsIn` so BOTH listings can call it; `collectImportedPkgVars(body, sm)` now builds the package's merge per copy, and `modelled()` keeps the three dynamic containers (the unpacked aggregates stay dropped — `emitPackageVar` still declines them at package scope, and the two listings must not disagree). |
| `src/ParamEmit.cpp` | `UhdmExporter::collectOobCtorLocals` forwards to it; `emitPackageVar`'s container arm no longer refuses the module copy — **except** for a container whose ELEMENT is a PACKED STRUCT, which golden's module DEF view lists and its ELAB view does not (grid arm F, measured on a golden of its own); `emitPkgArrayVar` takes `stampTsInstance` so the module copy's element typespec is not stamped at the module. |
| `src/ModuleEmit.cpp` | the two call sites pass `*sm`; the def-view net's typespec is built under `importedPkgVarTs203`. |
| `src/TypeEmit.cpp` | one clause: § `localClassTsUnnamed15`'s same-component suppression does not fire under `importedPkgVarTs203`. |
| `src/ExprEmit.cpp` | the `$dumpvars`/system-call scope-name arm reuses a net the module already lists before minting. |
| `include/UhdmExporter.h` | the `importedPkgVarTs203` flag and its law; `emitPkgArrayVar`'s new parameter. |

**MOVED-WRONG 0 / AWAY-GOLDEN 0**, scored key by key by `dir203.py` on all four
moved rows (`CENSUS.r10uvm203.txt`):

```
SimpleUVM/default    MISSING->RIGHT 46   WRONG->RIGHT 4   RIGHT->RIGHT 638   MOVED-WRONG=0
SimpleUVM/testflags  MISSING->RIGHT 46   WRONG->RIGHT 4   RIGHT->RIGHT 638   MOVED-WRONG=0
SeqDriver/default    MISSING->RIGHT 16   MISSING->WRONG 16   WRONG->WRONG 52   RIGHT->RIGHT 654   MOVED-WRONG=0
SeqDriver/testflags  (identical)
```

SeqDriver's sixteen `MISSING->WRONG` are **NAMEMULT** cells reading
`G={'2'} O={'1'}` where they read *absent* before: `top_tb` imports `uvm_pkg`
AND `adpcm_pkg`, and `adpcm_pkg` carries a transitive wildcard-import CLONE of
`uvm_pkg`'s 33 that the module hoist does not reproduce (R1). Going from 0 of 2
to 1 of 2 is TOWARD golden, and the arity confirms it: `work@top_tb` def NETS
golden 224, pristine **183**, patched **191**. Nothing on either row went
RIGHT→WRONG, and ONLY-OURS is **0 before and after** — a net golden does not
list does not appear.

## 6. THE HEAD AFTER — AND R0

```
LHS golden  design: (work@top), id:194978   |vpiTypespec ×123
RHS ours    design: (work@top)              |vpiTypespec ×89
```

`design::Compare` (`~/git-repos/UHDM/build/generated/src/design.cpp`) reads
`AllModules` at `:302` and `Typespecs` at `:303`. With the module's net vector
matched, the walk clears `AllModules` — every one of the 225 nets, in order —
and stops one line later on the design-level typespec vector. **That vector is
89 on the PRISTINE binary too** (`VECTORS.SimpleUVM.r10uvm203.txt`), so the head
was MASKED, not created; the 4177864-line log is the `design`'s own decompile
size.

**R0 — THE DESIGN-LEVEL `vpiTypespec` LISTING IS 34 SHORT ON SimpleUVM.**
Golden's `design->Typespecs()` holds 123, ours 89, on both binaries. It is the
next head both SimpleUVM modes, one field, and the first head this cluster
leaves that is not a module-scope listing.

## 7. THE GRID

`grid203.sh`, six arms × two views, one REAL Surelog golden per arm-view built
by the canonical `~/git-repos/Surelog/build/bin/surelog` that
`scripts/verify_golden.py` itself names.

```
-- CALIB    12 arm-views, AGREE 756, TS-DIFF  0, ONLY-GOLDEN   0, ONLY-OURS  0
-- PRIS     12 arm-views, AGREE 442, TS-DIFF 38, ONLY-GOLDEN 276, ONLY-OURS 76
-- PATCHED  12 arm-views, AGREE 672, TS-DIFF 16, ONLY-GOLDEN  68, ONLY-OURS 76
-- NONZERO RCs: 0
```

The grid is the brief's asked-for cross: **context kind × multiplicity × view.**

| arm | what it isolates | multiplicity | patched verdict |
|---|---|---|---|
| `g203_a_oob` | an out-of-body CONSTRUCTOR's function-body locals AND a nested `begin`'s, against an IN-BODY method's locals, a class PROPERTY, and an out-of-body NON-constructor — the four context kinds | **3** (file-level import ×2 + module-level ×1) | AGREE **110 = GCELLS** per view (pristine 68), ONLY-GOLDEN **0**, TS-DIFF **0**, both views. Slot-for-slot identical to golden, including the source (not alphabetical) order and the trailing `clk`/`cprop`. The in-body local, the property and the non-constructor's locals are correctly ABSENT on both sides. |
| `g203_b_cont` | the three DYNAMIC containers (`[string]`, `[$]`, `[]`) against the unpacked aggregates | 2 | AGREE 40 → **58**, ONLY-GOLDEN 38 → **20**. The three containers now materialize in both views; the remaining 20 are `b_fixed` and `b_ustruct`, which `emitPackageVar` still declines **at package scope too** on both binaries (R3). |
| `g203_c_mult` | the same constructor shape at **multiplicity 1** (module-scope import only) | **1** | AGREE **44 = GCELLS** per view (pristine 30), ONLY-GOLDEN **0**, both views. |
| `g203_d_dump` | `$dumpvars(0, <name>)` where the name COLLIDES with a hoisted net, beside a CONTROL name that no listing carries | 2 | AGREE **31 = GCELLS** per view, TS-DIFF **0**, ONLY-GOLDEN **0** (pristine: AGREE 19, TS-DIFF 5, ONLY-GOLDEN 7). The colliding name binds the materialized net (netType 0, `class_typespec Cd203`); the control still mints its `netType 1` wire — golden does both, and the pristine binary got the first one wrong in four distinct cells. |
| `g203_e_ctl` | NEGATIVE CONTROL: a package with an IN-BODY constructor and no container | 2 | **PATCHED identical to PRISTINE**, AGREE 42 = GCELLS both. It is correctly **absent** from the wide boundary's moved list. |
| `g203_f_pkstruct` | the ONE MEASURED EXCEPTION: four queues whose ELEMENTS are a packed STRUCT typedef, a packed UNION typedef, an int typedef and a class typedef, plus a bare class element as the control | 2 | the module side is **EXACT** — not one differing cell on `work@gf203`, in either view. Golden's DEF view lists all six declarations twice; its ELAB view lists five twice and **not** the packed-struct queue, and so does ours. AGREE 22 → **51**, ONLY-GOLDEN 41 → **14**, ONLY-OURS **18 → 18**; every remaining cell is on the PACKAGE `pf203`, whose own net/var split is a pre-existing residue identical on both binaries (R3b). |

`ONLY-OURS 76` is 4 cells × 12 arm-views (the `builtin` package's own ARITY
rows, which golden's `-nobuiltin` run has no scope for) plus arm F's 14
package-side net/var-split cells. It is **identical on both binaries, before
and after** — this law adds not one one-sided cell.

## 8. THE BOUNDARY AND THE FLOOR

```
LISTED=5305 PROCESSED=5305 PRODUCED_DBS=5120 MOVED_ARMS=84 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, PROCESSED is asserted
against LISTED). Four of this pass's five `grid203/g203_*.sv` are in the moved
list — the POSITIVE CONTROL, without which a green gate would prove nothing —
and `g203_e_ctl` is correctly absent.

**Every moved arm was rebuilt with a REAL Surelog golden in BOTH views and
scored** (`bscore203.sh`, `BOUNDARY_SCORES.r10uvm203.txt`):

```
-- SCORED views=167 MISSING-ARMS=0 NODB-views=1 TO-GOLDEN=2422 AWAY-GOLDEN=0
```

The one unscored view is `r10vbuvm31repro/gv31a5.sv elab`, where Surelog itself
fails (`grc=4`) and BOTH our binaries segfault — **identically**, `arc=139
brc=139`, which is why the boundary's own `RC_DIFFS` is 0. The counter records
it rather than hiding it.

A FIRST CUT OF THIS LAW SCORED **AWAY-GOLDEN 2**, on `r10buvm25repro/g25.sv`:
the module's elaborated copy of `S25 pq_st[$]` appeared where golden has no
such object. That is what grid arm F was built to decode and what
`emitPackageVar`'s packed-struct-element test now fences. The gate found it;
the law absorbed it; the re-run reads AWAY-GOLDEN 0.

**The FLOOR the brief names, checked BY NAME against
`BOUNDARY_MOVERS.r10uvm203.txt`:**

| boundary | arms in the moved list |
|---|---|
| § `impFoldRhsMirrorsLhsTs201` (`r10uvm201repro`) | **0** |
| § `impUnsizedBasedLhsNoTs199` + the paren-cast arm (`r10uvm199repro`, `r10v199repro`) | **0** |
| § `impCopyStringConstSize` (`r10uvm197repro`) | **0** |
| § `modUnitImportParamsTwice196` (`r10uvm196repro`) | **0** |
| buvm3–15 | **0** |
| uvm82–91 | **1** — `r10uvm87repro/v87_a3_oob.sv`, an OUT-OF-BODY arm, i.e. this law's own shape. Scored: AGREE 25→**27**, ONLY-GOLDEN 2→**0**, AWAY **0**, both views |
| sd8–12 | **6** — `sd9/10/11/12 grid9/g3_pkgvar_module.sv` (a PACKAGE-VARIABLE-IN-MODULE arm; AGREE 38→**52**, ONLY-GOLDEN 18→**6**, AWAY **0**), `sd11/12 vgrid11/v1_nonsubroutine_sites.sv` (AGREE 35→**44**, ONLY-GOLDEN 20→**8**, AWAY **0**), `sd12 grid12/h4.sv` (AGREE 17→**22**, ONLY-GOLDEN 4→**0**, AWAY **0**) |

Every one of those is an arm whose subject IS the materialized-import listing,
every one moves TOWARD golden, and none of them moves away.

## 9. RESIDUES, ranked

* **R0 — the design-level `vpiTypespec` listing is 34 short on SimpleUVM**
  (§ 6). Golden 123 / ours 89, on BOTH binaries. The current head, both
  SimpleUVM modes, one field.
* **R1 — the TRANSITIVE-IMPORT half of this law.** A package that
  wildcard-imports another carries a CLONE of that package's whole listing
  (`emitPackage`'s `impVars9`, r10uvm3), and a MODULE importing the first one
  must materialize those clones too. It does not: SeqDriver's `work@top_tb`
  lists 191 nets where golden lists 224, and the missing 33 are exactly
  `adpcm_pkg`'s clone of `uvm_pkg`'s listing. That is the whole of SeqDriver's
  remaining `ONLY-GOLDEN 66` on this face and the sixteen `MISSING->WRONG`
  multiplicity cells.
* **R2 — the INTERFACE half.** Surelog materialises the import into an
  `interface_inst` as well: MiniAmiq's `work@svaunit_vpi_interface` lists 71
  nets in golden and 5 in ours, the missing block being uvm_pkg's 33 × 2.
  `collectImportedPkgVars` is called from the module emitters only. MiniAmiq's
  cmp head is r10uvm202's, so this pass deliberately did not reach for it;
  the census face is `ONLY-GOLDEN 99`, unchanged by this pass on both binaries.
* **R3b — the package's own NET/VAR SPLIT for a TYPEDEF'd container.** Golden
  lists `Sf203 q[$]` (and the union / int-typedef / class-typedef forms) among
  the PACKAGE's `vpiNet`s, typed by the element; we list them among its
  `vpiVariables` as `array_var`s. Grid arm F's whole remaining `ONLY-GOLDEN
  14` / `ONLY-OURS 14` and its 4 TS-DIFF cells, identical on both binaries.
  This pass deliberately did not touch the package side: the module hoist now
  mirrors whatever that side produces, so the two move together when it is
  fixed.
* **R3 — the UNPACKED AGGREGATES are still dropped**, at package scope AND in
  the module copy: `int b_fixed[4]` and an unpacked-struct array are absent
  from `pb203`'s own `Variables()` on both binaries (grid arm B, `ONLY-GOLDEN
  20`). `emitPackageVar` declines them by name; this pass kept that decline so
  the two listings cannot disagree.
* **R4 — the implicit-wire block's ORDER.** Our 157 `netType 1` wires on
  SimpleUVM's `work@top` are the same multiset as golden's in a different
  order. It is judge-INVISIBLE (§ 2: no ancestor of `logic_net` compares
  `VpiName`) and therefore not a head, but it is a dump-text difference.
* **R5 — the `Earlgrey_0_1/testflags` dump-column cell in the COMMITTED
  baseline.** This pass's PRISTINE binary already reports
  `Earlgrey_0_1,testflags,CMP_EQUAL,,,` where `results/golden_surelog.csv`
  records `…,CMP_EQUAL,,,differ` — the STATUS agrees, only the informational
  dump column differs, and it differs on the pristine binary too (r10uvm197,
  r10uvm199 and r10uvm201 recorded the same cell). Not this pass's; nothing was
  promoted; `results/*.csv` were read only.

## 10. HOW TO REPRODUCE

```bash
git worktree add /tmp/wt_r10uvm203 8a67584d
cd /tmp/wt_r10uvm203 && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2   # pristine, md5 c2343ac3…
cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris
git apply /tmp/r10uvm203.patch && cmake --build build -j 2           # patched
cp build/slang-uhdm /tmp/pat && chmod 555 /tmp/pat   # md5 b801e95a…, byte-identical
                                                     # when the patch is applied to a
                                                     # FRESH 8a67584d worktree and rebuilt
cd tools/probe/r10uvm203repro
g++ -O2 -std=c++17 ct203net.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct203net
g++ -O2 -std=c++17 ct203cen.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct203cen
g++ -O2 -std=c++17 ct203pred.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct203pred
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=$PWD/ct203cen JOIN=$PWD/cen203.py \
  bash grid203.sh $PWD/grid203 /tmp/gs /tmp/GRID.txt                    # the grid
bash pred203.sh <pristine sweep workdir> $PWD/ct203pred /tmp/PRED.txt   # the prediction
PRIS=/tmp/pris PATCHED=/tmp/pat bash bound203.sh <a COPY of tools/probe> /tmp/bd
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=$PWD/ct203cen JOIN=$PWD/cen203.py \
  bash bscore203.sh <that copy> /tmp/bd/MOVERS /tmp/bs                  # score the movers
bash scrub203.sh <any artifact that walked a sweep workdir>             # then canaudit
```

The three probe binaries are NOT committed (they are 5.7 MB each and rebuild in
seconds from the committed sources).
