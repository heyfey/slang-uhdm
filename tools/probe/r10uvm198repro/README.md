# r10uvm198 — § `classScopedTdImportCopyLocalUnsupported198` — **A WILDCARD-IMPORT CLONE KEEPS THE PRE-REPAIR PLACEHOLDER OF ITS BODY'S CLASS-SCOPE TYPEDEF LOCALS** — the SeqDriver ×2 and MiniAmiq ×2 198-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f7a77143` |
| pristine binary | md5 `a2733a6622a01308a82a434a9e747d5e`, built from this pass's OWN worktree at a clean `f7a77143` and frozen `chmod 555` before any sweep — **byte-identical to the master's own pristine at that commit** |
| patched binary | md5 `ca837653759ad48756a9288c316d75d3`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law, the Surelog decode and the predicate `clsScopedTdLocalName198`), `src/TaskFuncEmit.cpp` (SITE 1 of 2, the subroutine-body local), `src/StmtEmit.cpp` (SITE 2 of 2, the block-item local) |
| probe surface | `tools/probe/r10uvm198repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default and testflags, 198 cmp lines, ONE head each → 33**; **MiniAmiq default and testflags, 198 → 33**. One object in all four row-modes, before and after. A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7). |
| corpus rows changed | **0** — both corpora, both modes, against THIS PASS'S OWN pristine sweep. Against the committed baseline exactly one row-side differs, `Earlgrey_0_1,testflags` `CMP_EQUAL/differ` → `CMP_EQUAL/`, and it reads the SAME way in this pass's own PRISTINE sweep: a uhdm-dump TIMEOUT under sweep load, not a model change. **NO ROW WAS CONVERTED**; `results/*.csv` were not edited. |
| byte movers | **5 / 956** surelog — the FOUR the prediction named BY NAME from the pristine databases alone, plus Scoreboard/default, the ~50/50 COIN, whose ORDER-BLIND dump diff is **0 content lines**. **0 / 1358** uhdm2rtlil. |
| the corpus population | **8 cells per moved row-mode**, four declarations × two views, all in the wildcard-import clone: `uvm_component::m_set_cl_verb`'s `m_verbosity_setting setting`, `m_set_cl_action`'s and `m_set_cl_sev`'s `uvm_cmdline_parsed_arg_t t`, and `m_apply_verbosity_settings`'s `m_verbosity_setting setting`. |
| the census (nine UVM row-modes, golden-vs-golden calibrated first) | SeqDriver ×2 and MiniAmiq ×2: **TO-GOLDEN 4 keys, AWAY-GOLDEN 0, MOVED-WRONG 0**. SimpleUVM ×2, Scoreboard/default and **BuildUVMPkg ×2 (a protected CMP_EQUAL row): all three columns 0**. |
| the grid (5 arms, both views) | **TO-GOLDEN 29 per view, AWAY-GOLDEN 0, MOVED-WRONG 0.** Arm A goes CMP_EQUAL in BOTH views on the patched binary (96 lines / one head → 0 / 0). |
| the a-priori prediction | `strict` non-zero on **exactly four row-modes over 948 scanned surelog databases** and on **none of the 1358** uhdm2rtlil ones, where the law's WIDE bound is empty outright. |
| the WIDE boundary (5226 arms, both views) | `LISTED=5226 PROCESSED=5226 PRODUCED_DBS=5041`, **RC_DIFFS 0, MOVED_ARMS 8**: **5 are this pass's own grid arms** (the positive control), and the 3 others are rebuilt against their own goldens in §7 — TO-GOLDEN 2/2/2 def and 4/2/2 elab, AWAY-GOLDEN 0, MOVED-WRONG 0. |
| the protected rows | BuildUVMPkg ×2 and Earlgrey_0_1/testflags stay CMP_EQUAL and their databases are byte-identical to the pristine sweep's; SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` PINS HELD; InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep of its own `f7a77143`
worktree — the binary came out byte-identical to the master's frozen pristine
(`a2733a66…`):

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default        198      1
SeqDriver      testflags      198      1
MiniAmiq       default        198      1     (the two modes' logs are byte-identical)
MiniAmiq       testflags      198      1
```

All four heads are the SAME object pair:

```
LHS: unsupported_typespec: (m_verbosity_setting), line:3393:5, endln:3393:24
     |vpiParent: \_ref_typespec: (adpcm_pkg::uvm_component::m_set_cl_verb::setting)
     |vpiName:m_verbosity_setting
     |vpiInstance: \_package: uvm_pkg
RHS: struct_typespec: (m_verbosity_setting), line:1686:11, endln:1692:4
     |vpiParent: \_class_defn: (uvm_pkg::uvm_component)
     |vpiName:m_verbosity_setting   |vpiTypespecMember: comp/phase/offset/verbosity/id
```

uvm-1.2 `base/uvm_component.svh:1686` declares `typedef struct {...}
m_verbosity_setting;` INSIDE class `uvm_component`, and `:3393`
(`m_verbosity_setting setting;`) is a local of the `begin` of
`foreach(values[i])` inside the OUT-OF-BODY method
`uvm_component::m_set_cl_verb` — read in the wildcard-import CLONE the importing
package `adpcm_pkg` holds.

## 2. DECODING THE JUDGE FIRST — `ct198own`

`ct198own.cpp` links the SAME generated `Compare` the judge does and answers
four questions on the pristine pair. The failing FIELD is the KIND: both sides
are present, so `BaseClass::Compare`'s `VpiType` line fails before `VpiName`
(which agrees) and before `Instance` (which does not).

**THE OWNER.** Golden's head has exactly ONE referrer and it is the edge the
judge walked:

```
REF .Actual_typespec  rel1  ref_typespec#204662
     < ref_var(setting)@uvm_component.svh:3393:25-3393:32
     < begin()@3392:22-3430:6  < foreach_stmt()@3392:3
     < begin()@3387:3          < function(uvm_component::m_set_cl_verb)@3375:1
     < package(adpcm_pkg)      < design
```

**THE MINT.** Golden holds **6** `unsupported_typespec` objects named
`m_verbosity_setting`, every one of them instanced at `package uvm_pkg` and
every one of them under `package adpcm_pkg` — the CLONE — with `refs=1` each:
three per view (one in `m_set_cl_verb`, two in `m_apply_verbosity_settings`,
whose `fork` local is listed twice). **Golden mints one placeholder per
declaration and shares none of them**, and its HOME (`uvm_pkg`) and class views
hold NONE.

Ours holds **1** `struct_typespec(m_verbosity_setting)` with **11** referrers:
the `class_defn`'s own `Typespecs[0]`, the two class properties, and eight
declaration bindings — two in the class views, two in `uvm_pkg`'s own two views
and **four in `adpcm_pkg`'s two clone views**. Those last four are the cells
this law rewrites; the other seven must not move, and the census below scores
them.

**THE ABLATION.** Masking the golden head in a fresh `CompareContext` moves the
judge to `unsupported_typespec(uvm_cmdline_parsed_arg_t)@3475:3` against our
`struct_typespec(uvm_cmdline_parsed_arg_t)@1701:9` — the SAME law, one class-scope
typedef over (`uvm_component::m_set_cl_action`'s `uvm_cmdline_parsed_arg_t t;`).
So the head is not one object but a family, and the law had to clear all of it.

## 3. DECODING SURELOG — THE CLONE COPIES AN ALREADY-DEGRADED HOME OBJECT

The question this pass had to settle was whether § 36's window RE-COMPILES the
cloned body in the importer's scope (where the class's type table is missing) or
whether the importer COPIES a home object that was degraded and then repaired.
It is the second, and three Surelog sites say so:

1. **The home body degrades FIRST.** `compileVariable`'s final arm
   (`CompileType.cpp:421-431`) mints a `ref_var` and, when `compileTypespec`
   answered an `unsupported_typespec`, registers the declaration for late
   repair: `component->needLateTypedefBinding(ref)`. The block-item form does
   the same at `CompileStmt.cpp:1799-1806`. A class-scope typedef is not in the
   PACKAGE's data-type map, and an out-of-body method is a package item, so the
   home's own copy takes this arm — which is exactly why golden's variable is a
   `ref_var` in the HOME as well as in the clone (grid arm A, every cell).
2. **The importer copies at COLLECT time.**
   `CompilePackage::collectObjects_`'s `CollectType::FUNCTION` pass calls
   `m_helper.importPackage(...)` (`CompilePackage.cpp:141-151`, `:167-170`),
   and `CompileHelper::importPackage` deep-copies each imported task_func with
   `UHDM::clone_tree` when the importer is a package
   (`CompileHelper.cpp:299-324`). The copy therefore carries a COPY of the
   placeholder — including its `vpiInstance`, the HOME package.
3. **The repair is POINTER-KEYED and cannot reach the copy.**
   `ElaborationStep::bindTypedefs_` walks `comp->getLateTypedefBinding()` and
   records `getSwapedObjects().emplace(orig_ut, tps)` — keyed on the ORIGINAL
   placeholder object (`ElaborationStep.cpp:303-321`, `:334-408`) — and
   `swapTypespecPointersInUhdm` (`:415`, body at `:554-637`) then rewrites every
   `expr`'s `Typespec` in the whole serializer (`:632-634`, and a `variables`
   IS-A `expr`). The clone's `ref_typespec` points at its own copied object,
   which is not a key in that map, so the home is repaired and the clone is not.

Everything the grid measures follows from this and needs no further predicate:
the KIND of the typedef is irrelevant (nothing in the mechanism reads it), the
DECLARING SCOPE is what decides (a package-scope typedef resolves at first
compile and is never degraded, so its copy carries the real typespec), and the
HOME's own def/elab/class views keep the resolved object.

## 4. DECODING SLANG — TWO SITES, ONE GATE

Our emitter resolves the class-scope typedef everywhere, because
`makeTypespec` answers from the CLASS's own table whatever body it is emitting.
The clone is emitted by `ParamEmit.cpp`'s package class-method clone driver
(`~23637`), which sets `importCopyTsInst` to the HOME package's def object and
collects every typespec the clone mints into `importCopyTsFixups`, the list that
re-points them at the ELABORATED home once both views exist.

`src/EmitHelpers.h`'s `clsScopedTdLocalName198` is the predicate and the NAME:
the declared type must be a `TypeAlias` whose parent scope is a `ClassType` or
`GenericClassDef`, the spelling must be scalar (the ARRAY fence — an array
local's placeholder lives on the ELEMENT `ref_var`, which is not these sites,
the same fence § `oobClassTypeParamLocalUnsupported105` states), and the name is
the WRITTEN one — the bare identifier, or `<first>::<last>` for a two-segment
spelling (golden's `Kiln198::potSt198`, `Inner198::innerSt198`); a longer
spelling is DECLINED rather than guessed at.

The two call sites are the two the corpus and the grid need:

* `src/TaskFuncEmit.cpp` — the SUBROUTINE-BODY local, and
* `src/StmtEmit.cpp` — the BLOCK-ITEM local, where the corpus head lives.

Both are LAST in their site's placeholder chain, after
§ `builtinClassLocalUnsupportedBeforeClassPhase115`,
§ `oobClassTypeParamLocalUnsupported105`,
§ `blockLocalTdDeclIsRefVarUnsupported155` and
§ `classScopedTdDeclTsUnsupported11` — each of which owns its cells in EVERY
view, home included, while this law owns only what is left inside a CLONE. Only
the KIND, the NAME and the INSTANCE move; the variable's own class, span,
parent, full name and `vpiAutomatic` stay where the surrounding laws put them
(golden's clone cell is the very `ref_var` / `class_var` we already emit).

## 5. THE GRID — five arms, one real Surelog golden each, both views

`GRIDS.r10uvm198.txt` carries the scored runs; every arm is scored with
`ct198cen` + `score198.py` over JUDGE-VISIBLE payload only.

| arm | what it decides | def | elab |
|---|---|---|---|
| A `g198_a_homes` | class vs PACKAGE declaring scope, with a package-STRUCT and a package-INT control in the SAME cloned body | TO-GOLDEN 6, AWAY 0, WRONG 0 | 6 / 0 / 0 |
| B `g198_b_kinds` | struct, enum, union, string, packed vector, int, alias-of-package-typedef, class-handle typedef, and the SCOPED spelling; § 36's FORMAL cell as a must-stay | 9 / 0 / 0 | 9 / 0 / 0 |
| C `g198_c_scopes` | nested class, PARAMETERISED class, typedef INHERITED from a base class | 4 / 0 / 0 | 4 / 0 / 0 |
| D `g198_d_sites` | tf-item, tf-item with initialiser, ARRAY, named begin, loop body, if arm, case item, fork arm | 9 / 0 / 0 | 9 / 0 / 0 |
| E `g198_e_head` | the corpus head minimised — the POSITIVE CONTROL | 1 / 0 / 0 | 1 / 0 / 0 |

**AWAY-GOLDEN 0 and MOVED-WRONG 0 on every arm in every view**, and arm A goes
CMP_EQUAL in BOTH views on the patched binary (96 cmp lines with one head → 0).
Arm A's PACKAGE-scope controls, of the very same struct kind, in the very same
cloned body, do NOT move — that control is what keeps this law from degrading
every clone local, exactly as § 36's `k50_t` keeps its own from degrading every
clone formal.

Every remaining STILL-WRONG cell reads the same on both binaries (`pris ==
pat`) and is named in R1–R4 below.

## 6. THE CENSUS, THE PREDICTION AND THE MOVERS

`PREDICT.surelog.r10uvm198.txt` and `PREDICT.u2r.r10uvm198.txt` were written by
`predict198.sh` + `ct198pred` from the **PRISTINE** sweep workdirs alone, before
the patched sweep was read. The criterion is the one the emitter rewrites,
expressed in the database the emitter produced: a listing slot of a subroutine
whose name carries `::`, listed under a package, bound to a typespec that is not
already a placeholder and IS parented at a `class_defn` of another package.

```
surelog   scanned=948 NODB=617 FENCED=8
  PREDCELLS MiniAmiq,default   strict=8      PREDCELLS MiniAmiq,testflags  strict=8
  PREDCELLS SeqDriver,default  strict=8      PREDCELLS SeqDriver,testflags strict=8
  every other row strict=0 — including BuildUVMPkg ×2, SimpleUVM ×2 and
  Scoreboard, which DO hold clone-body locals (a non-empty WIDE bound) and
  none typed by a class-scope typedef
uhdm2rtlil scanned=1358 NODB=104 FENCED=0
  no row, and the WIDE bound is EMPTY over the whole corpus
```

The patched sweep moved **exactly those four rows**, plus Scoreboard/default,
the coin, whose ORDER-BLIND dump diff is 0 content lines (94 plain lines, the
known `svunit_pkg` `vpiTaskFunc` order flip). `MOVERS.r10uvm198.txt` names every
mover and its attribution; `CENSUS.r10uvm198.txt` carries the nine UVM row-modes
with the golden-vs-golden calibration first and the four moved keys in full.

The predictor also prints a WIDE bound — every clone-body local binding that is
not already a placeholder — because the strict criterion can only UNDER-predict
(grid arm B's class UNION and class STRING locals resolve to objects our own
emitter parents elsewhere, and the emitter still fires on them, correctly).
Every observed mover is inside that bound and every strict cell moved.

## 7. RESIDUES AND R0

* **R0 — the NEXT HEAD, and it is a different object and a different family.**
  SeqDriver ×2 and MiniAmiq ×2 now read **33 cmp lines, one head**, and it is a
  MIRROR head: `LHS: <null>` above OUR `constant` (`vpiDecompile:115199`,
  `INT:115199`, `vpiSize:32`, `vpiConstType:7`) at `410:30-410:60`, under
  `param_assign()@410:11-410:62` in the IMPORTING package (`adpcm_pkg` /
  `svaunit_pkg`), with `ref_typespec(<importing package>) -> int_typespec`.
  `ct198own` on the patched pair names the single edge golden leaves null:
  `REF .Rhs rel1 param_assign()@410:11 < package(adpcm_pkg) < design`. The
  construct is uvm-1.2 `base/uvm_globals.svh:410`
  `parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;` (= 115199):
  **the IMPORT COPY of a package parameter carries a folded `Rhs` constant in
  ours and NO `Rhs` in golden.** MiniAmiq's two modes are byte-identical.
  Decode it with the owner-finder and `CompileHelper::importPackage`'s
  `ParamAssign` clone arm (CompileHelper.cpp:241-279) first — that arm clones
  the param_assign with `clone_tree` and re-points its `Lhs` only.
* **R1 — the ARRAY FENCE.** An array local of a class-scope typedef keeps its
  placeholder on the ELEMENT `ref_var`, which is neither of this law's two
  sites; grid arm D `dArr198` slot 2 is the cell, and it is wrong in the HOME
  view too (ours emits an unnamed `logic_typespec` where golden has the
  resolved struct), so closing it is an ELEMENT-site law, not this one.
  Unmoved on both binaries.
* **R2 — the clone's PACKAGE-typedef instance.** An AGGREGATE package typedef
  local inside a clone takes the IMPORTING package as its typespec instance
  where golden takes the HOME (arm A `tfPkg198` / `blkPkg198`, arm B
  `kPkg198`). The KIND and the NAME already agree, so this is an instance-stamp
  law one construct over. Unmoved.
* **R3 — home-view kind residues.** A class-scope UNION local resolves to a
  `logic_typespec` and a class-scope STRING local to an unnamed
  `string_typespec` in the HOME views (arm B `kUn198` / `kStr198`), and an
  alias-of-a-package-typedef's instance reads the importing package. All
  pre-existing, all unmoved; the CLONE halves of those same declarations DID
  move to golden, which is what says the law is scope-keyed and not kind-keyed.
* **R4 — the THREE-segment spelling.** `w4a::akc::ak_s` written in a clone body
  (boundary arm `r10buvm9repro/w4v_imports.sv`) reads, in golden,
  `unsupported_typespec w4a::ak_s` instanced at the **DECLARING** package `w4c`
  — a different name AND a different instance from this law's. The law DECLINES
  it by its stated fence and the cell did not move.

## 8. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm198repro
g++ -O2 -std=c++17 ct198cen.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct198cen
g++ -O2 -std=c++17 ct198pred.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct198pred
g++ -O2 -std=c++17 ct198own.cpp  -I ~/.local/include -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct198own

# the judge decode, on the head's own row
/tmp/ct198own <golden.uhdm> <ours.uhdm> --refs --mint

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid198/g198_*.sv; do CEN=/tmp/ct198cen bash grid198.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv); done
python3 score198.py /tmp/w_g198_a_homes/cen.g.def.txt /tmp/w_g198_a_homes/cen.a.def.txt /tmp/w_g198_a_homes/cen.b.def.txt --show

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct198pred bash predict198.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the UVM row-modes
CEN=/tmp/ct198cen bash cen198.sh <pristine workdir> <patched workdir> /tmp/cen

# the wide boundary
PRIS=<PRISTINE> PATCHED=<PATCHED> bash bound198.sh <a COPY of tools/probe> /tmp/bnd

# the canary audit
bash canaudit.sh canaries.sh ctcan2.sh
```
