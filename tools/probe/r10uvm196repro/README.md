# r10uvm196 — § `modUnitImportParamsTwice196` — **A FILE-SCOPE `import P::*` MATERIALIZES P's PARAMETERS INTO EVERY MODULE, INTERFACE AND PROGRAM WRITTEN IN THAT FILE, TWICE PER IMPORT ITEM** — the SimpleUVM ×2 664681-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here; the corpus censuses walk a sweep workdir that contains them, so
`scrub196.sh` redacts their names out of every artifact — reading the fence
list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `c3e022a3` |
| pristine binary | md5 `4a42bc7a0018bc97d6d57ceebe1a0a9d`, built from this pass's OWN worktree at a clean `c3e022a3` and frozen `chmod 555` before any sweep — its own 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduced the committed baselines **row for row** |
| patched binary | md5 `b319e3a6663d2992cbafd747f74a2ffc`, frozen `chmod 555`. The patch applied to a **FRESH `c3e022a3` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on |
| production surface | `src/ParamEmit.cpp` only — one list of import ITEMS built ahead of the existing loop in `collectImportedParams`, plus the decode. Nothing deleted, no name written, no object re-pointed. |
| probe surface | `tools/probe/r10uvm196repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 664681 cmp lines, ONE head each → 62**, on a different object of a different kind (§8). Both modes. |
| every other row's head | cmp log **BYTE-IDENTICAL** between the two binaries — SeqDriver ×2 29, Scoreboard/default 95, MiniAmiq ×2 29, BuildUVMPkg ×2 **0**, Earlgrey_0_1 31 / **0**, Rggen/default 0. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND this pass's own pristine sweeps. 1588 surelog rows, 731 + 731 uhdm2rtlil rows. `BuildUVMPkg` ×2 and `Earlgrey_0_1/testflags` stay **CMP_EQUAL**. |
| byte movers | **2 / 956** surelog — `default/SimpleUVM` and `testflags/SimpleUVM`, **both PREDICTED BY NAME before the patched binary existed**, from PRISTINE databases alone, by TWO independent predictors (§6). **0 / 1358** uhdm2rtlil, also predicted (that corpus holds **no cell of this face at all**: 1358 databases, GOLDEN-ONLY-COUNT 0). |
| the census (956 + 1358 databases, golden × ours, both listings) | AGREE **81797 → 82517** (+720); **GOLDEN-ONLY-COUNT 720 → 0**; OURS-ONLY-COUNT 1392 → 1392 (untouched, a different family — R2). **TO-GOLDEN 720 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0.** |
| the grids (3 arm sets, 8 sources, both views, one REAL Surelog golden each) | **TO-GOLDEN 688, AWAY 0, MOVED-WRONG 0, MISSED 0**; every arm set reaches GOLDEN-ONLY 0 **and** OURS-ONLY 0 in both views; every rc recorded, 0 nonzero. |
| the WIDE boundary (5189 sources × 2 views) | `LISTED=5189 PROCESSED=5189 PRODUCED_DBS=5018 MOVED_ARMS=53 RC_DIFFS=0`. One is this pass's own POSITIVE CONTROL. Each of the other **52 was rebuilt with a REAL Surelog golden in BOTH views and scored: TO-GOLDEN 2440, AWAY-GOLDEN 0**, 0 arms unbuildable. |
| the FLOOR | uvm192's 4 arms, uvm193's 4, uvm184's 2 **with both fences**, uvm194's 3, uvm186/189/191's 3 each, uvm185's 5, uvm190's 4, uvm187's 6, uvm188's 4, uvm170's 5, uvm82–91's 113, buvm3–15's 119, sd8–12's 347 — **34 families, 625 arms, MOVED = 0** (§9). |
| gates | goldens **23/0**, negative control **0/23**; canaries `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS ×2; `canaudit` PASS, `FENCE-BREACH=0`; all 10 protected databases SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `c3e022a3` worktree. Its
956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduced the
committed baselines row for row (`ct8rows` PASS, 0 differing rows, status AND
dump column). Every `cmds.txt` in every sweep names this pass's own frozen
binary, audited BY PATH (1523 + 1458 rows).

`rowheads.sh` on that sweep put SimpleUVM at **664681 cmp lines, ONE head**,
both modes — the R0 r10uvm179 named.

```
LHS golden  module_inst: work@top, id:197492, testbench.sv, line:44:1, endln:71:10
RHS         <null>
```

The line count is the head OBJECT's decompile size, not a distance.

## 2. THE BRIEF'S FRAMING, REFUTED FIRST — THE `run_test` BINDING IS ALREADY CORRECT

The brief names the head as *"the task_call (run_test) at testbench.sv:56:5 and
its Task field, both candidates FACE-IDENTICAL, so the decode must work at
IDENTITY level"*, and asks which task object each side binds. **Both sides bind
the same one, at the same index of the same listing**, and no binding law is
needed. `ct196own`'s STEP 4 answers it by POSITION, on the pristine databases:

```
GOLDEN task(run_test)@38:1-44:8 #766    TopPackages[1](uvm_pkg).Task_funcs[34]/58
OURS   task(run_test)@38:1-44:8 #5020   TopPackages[1](uvm_pkg).Task_funcs[34]/58
   (the other twin, on both sides, is AllPackages[1](uvm_pkg).Task_funcs[347]/894)
```

Same view, same index, same arity — the `task_call::Task` edge is not the
defect. r10uvm179's DESCENT reached that pair because its walk follows
`VpiParent` children and asks each pair whether its own `Compare` REPRODUCES
the design-level head; on a design this size a great many pairs do, because
almost every object reaches `module_inst work@top` through some link
(`ct196chase` shows a `typespec::Instance` route from the DESIGN back to the
head in four hops, and a cycle after that). **Reproducing the head is not the
same as being the edge that produced it.**

## 3. DECODING THE JUDGE — THE HEAD IS A MISSING VECTOR, AND THE OWNER IS THE HEAD

`RHS: <null>` with the LHS present is one of TWO `BaseClass.h` arms
(RESUME §9): the SINGULAR overload naming a VALUE, or the **VECTOR** overload's
`(lhs != nullptr) && !lhs->empty() && (rhs == nullptr)` branch, which sets
`m_failedLhs = lhs_obj` — **the OWNER, not the value** — and leaves the RHS
unset. `ct196chase --headowner` settles it by dumping the head object's own
edges against its counterpart, generically through `GetByVpiType`:

```
counterpart on our side: module_inst()@44:1-71:10 #178975   (exactly one)
  edge 36  (vpiNet)        VEC  Lsize=225  Rsize=210
  edge 40  (vpiParamAssign) VEC  Lsize=90  Rsize=NULL   <== NULL ON OUR SIDE
  edge 41  (vpiParameter)   VEC  Lsize=90  Rsize=NULL   <== NULL ON OUR SIDE
  edge 99  (vpiProcess)     VEC  3 / 3
  edge 127 (vpiTaskFunc)    VEC  894 / 894
  edge 725 (vpiTypedef)     VEC  123 / 123
```

`scope::Compare` (`~/git-repos/UHDM/build/generated/src/scope.cpp:335-351`) is
the FIRST thing `instance::Compare` runs, and inside it `Parameters` is the
eleventh vector and `Param_assigns` the twelfth — both **before**
`instance::Compare`'s `Nets` (`instance.cpp:332-341`) and before
`module_inst::Compare`'s own fields. So the judge stops on `Parameters`: golden
90, ours NULL. That is exactly an LHS-only head naming the OWNER, and it is why
the count is a decompile size.

**The `Nets` 225 vs 210 is a REAL and SEPARATE difference that this law does not
touch** — it is simply reached later (R1).

`ct196pop` then names the population on both views of the top module:

```
                        golden                    ours (pristine)
DEF  view #197492    Parameters 90  Param_assigns 90    NULL   NULL
ELAB view #197854    Parameters 90  Param_assigns 90    NULL   NULL
     Typespecs 123 = 123, Task_funcs 894 = 894 on both views and both sides
```

We already hoist the imported package's TYPEDEFS and its whole SUBROUTINE
listing into this module and get both exactly right. **Only the PARAMETER half
was missing**, and all 90 rows carry `vpiImported = uvm_pkg`.

## 4. DECODING SURELOG

**`CompileModule::collectModuleObjects_`**
(`~/git-repos/Surelog/src/DesignCompile/CompileModule.cpp:568-580`), in the
`CollectType::FUNCTION` pass, opens with

```cpp
std::vector<FileCNodeId> pack_imports;
// - Local file imports
for (auto import : fC->getObjects(VObjectType::paPackage_import_item))
  pack_imports.push_back(import);
for (auto pack_import : pack_imports)
  m_helper.importPackage(m_module, m_design, pack_fC, pack_id, m_compileDesign);
```

`fC` is the module's own `FileContent`, which is itself a `DesignComponent`, so
`getObjects` returns the import items **the FILE ($unit) registered** — and each
is materialized INTO THE MODULE, before the tree walk below ever reaches the
module's own `paPackage_import_item` case (`:601-605`, the once-per-body arm we
already model). `CompileModule::collectInterfaceObjects_` (`:1055-1068`) and
`CompileProgram::compile` (`CompileProgram.cpp:122-135`) carry the same block
verbatim, which is why an INTERFACE and a PROGRAM take the copies too.

### THE GOLDEN TABLE — measured, not assumed (`grid196`, real Surelog goldens)

| arm | the module's import situation | golden copies | ours (pristine) |
|---|---|---|---|
| `g196_a_fileimp.sv` `aFileOne`, `aFileTwo` | a FILE-scope `import p::*` in its own file | **2** | 0 |
| `g196_b_bodyimp.sv` `bBody` | a MODULE-BODY `import p::*` | **1** | **1 — agrees** |
| `g196_c_both.sv` `cBoth` | both, same package | **3** | 1 |
| `g196_c_both.sv` `cFileOnly` | the file item only | **2** | 0 |
| `g196_d_other.sv` `dOther` | a module in a file with NO import | **0** | **0 — agrees** |
| `g196_e_kinds.sv` `eMod` / `eIf` / `eProg` | a file item, module vs INTERFACE vs PROGRAM | **2 each** | 0 |
| `g196_f_explicit.sv` `fExp` | two EXPLICIT file items | **2 each** | 0 |
| `g196_g_order.sv` `gLocalPkg` | a PACKAGE declared in a file that carries two file items | **0** | **0 — agrees** |

So the multiplicity is 2 for a file item, 1 for a body item, and they **ADD**;
the same-buffer term is real even under `--single-unit` (`dOther`); and
**packages are excluded** — a package's own body import still materializes once
(`masonPkg` imports `quarryPkg` and lists 4 + 1 = 5, golden and ours alike).

### THE DOUBLING IS PER ITEM AND ADJACENT — the arm that TESTS rather than agrees

A "per pass" doubling and a "per item" doubling produce the same listing
whenever one package is imported once, which is every corpus site. **`g196_g_order.sv`
separates them**: its file carries `import quarryPkg::*; import masonPkg::*;`
and its module BODY imports a third package. Golden's `work@gOrder`:

```
[0..3]   quarryPkg (4, NAME order)   [4..7]   quarryPkg again   <- file item 1, TWICE
[8..12]  masonPkg  (5)               [13..17] masonPkg  again   <- file item 2, TWICE
[18]     gLocalPkg (1)                                          <- the BODY item, ONCE
[19]     G_OWN                                                  <- the module's own, LAST
```

quarry, quarry, mason, mason — **not** quarry, mason, quarry, mason. The
two-explicit-item arm says the same with `import p::QUARRY_NAME;
import p::QUARRY_DEPTH;` → NAME, NAME, DEPTH, DEPTH. And the arm settles the
GROUP ORDER too: file items lead body items, and both lead the scope's own
parameters.

The WITHIN-item orders are the ones `collectImportedParams` already carries and
this arm re-measures: `Parameters` walks the package's parameter MAP (NAME
order — `QUARRY_DEPTH, QUARRY_LOCAL, QUARRY_NAME, QUARRY_UNTYPED`), while
`Param_assigns` walks its param-assign VECTOR (DECLARATION order — `DEPTH@5,
NAME@6, LOCAL@7, UNTYPED@8`). SimpleUVM is the corpus witness at scale: 45
uvm_pkg parameters, name-ordered in `Parameters`, declaration-ordered in
`Param_assigns`, each block repeated once (`ORDER.golden.r10uvm196.txt`).

## 5. DECODING SLANG — AND WHY IT IS ONE LIST, NOT A NEW WALK

`UhdmExporter::emitParameters` (`src/ParamEmit.cpp:3495`) already calls
`collectImportedParams` (`:2877`), which already owns the whole model: the
per-ITEM occurrence record `ImpOcc9` (§ `impOcc`), the transitive re-export
walk, the `vpiImported` tag, the two within-item orders, and the rule that
materialized copies LEAD the scope's own parameters. Its one gap was its input:

```cpp
for (auto& m : body.members())          // MODULE-BODY import items only
```

`body.members()` cannot see a compilation-unit import. § `collectMaterializedPkgs`
(`src/EmitHelpers.h:2204`) already reads exactly the right thing for the same
package's VARIABLES and SUBROUTINES — the definition's parent scope when it is a
`CompilationUnit`, filtered to the definition's own buffer, at multiplicity 2 —
so this law builds the ITEM LIST the same way and hands it to the loop
unchanged:

```
FENCE 1  the scope is an InstanceBodySymbol — a PACKAGE never reaches the
         compilation-unit walk (arm g196_g_order's gLocalPkg is the golden that
         convicts this term), and emitParameters already fences on !funcScope
FENCE 2  the parent scope must be a CompilationUnit
FENCE 3  the import member's BUFFER must equal the DEFINITION's buffer — not the
         instance's: SimpleUVM's `dut` is instantiated at testbench.sv:48 but
         DEFINED in design.sv, and golden gives it no copies (arm g196_d_other)
FENCE 4  each such item is pushed TWICE, ADJACENT, ahead of the body items
```

Everything downstream — the ordering key `(item, sub)`, the emit loop, the
`vpiImported` stamp, the def/elab shape flags — is untouched.

## 6. THE MOVERS, PREDICTED BY NAME BY TWO INDEPENDENT INSTRUMENTS

**PREDICTOR A — ours-only (`ct196cen --pred`, `predict196.sh`)**, run over the
PRISTINE sweeps before any patched binary existed. It needs no golden, so it
covers every database our binary produces:

```
surelog    PROCESSED=956  PREDICTED_MOVERS=2   default/SimpleUVM, testflags/SimpleUVM
uhdm2rtlil PROCESSED=1358 PREDICTED_MOVERS=2   default/ImportedFunctionUsesAnotherFunction, testflags/…
```

**PREDICTOR B — the compare-visible census (`ct196cen --cen`, `cen196.sh`)**,
golden × ours over the same pristine sweeps, each row's golden found through
THAT ROW'S OWN `cmds.txt`:

```
surelog    PROCESSED=956  NOGOLDEN=0  MOVER_ROWS=2   default/SimpleUVM, testflags/SimpleUVM
uhdm2rtlil PROCESSED=1358 NOGOLDEN=0  MOVER_ROWS=0
```

**They disagree on exactly one row, and B is right.** Predictor A flags
`ImportedFunctionUsesAnotherFunction` because that module materialized a
package (its subroutine group is hoisted) while listing zero imported
parameters — but its import is `import pkg::func_1;`, an EXPLICIT MODULE-BODY
import of a FUNCTION, so no parameter is materialized on either side and the row
is CMP_EQUAL. The fence leaves it alone and `byteverify` confirms it: **0
movers of 1358**. Predictor A's shape is an over-approximation by construction
(a database cannot show where an import was written); it is kept because it is
the only predictor that can speak for a row with no golden — and there are none
here: all 54 golden-less rows produce NO database of ours at all, so predictor
B covers 100% of the movable set.

`byteverify.sh SELFCHECK=1` then returned **exactly 2 of 956** and **0 of
1358**, `PATH_SETS_IDENTICAL` on both, SELFCHECK flagging 955/956 and 1357/1358
so the gate can see.

**Earlgrey_0_1 is NOT a mover, and a first cut of the census said it was.** Its
module-HEADER imports already give the right NUMBER of copies; only the
`vpiImported` TAG on one `param_assign` lhs of each pair differs (14 cells,
both modes, and its testflags row is CMP_EQUAL, so the judge does not see them).
A census keyed on `(kind, name, vpiImported)` alone called that a mover, so
`ct196cen` runs TWO joins — the TAGGED one and a COUNT one with the tag dropped
— and `GOLDEN-ONLY-COUNT` is the number the prediction uses. The same first cut
also used a last-writer `key → instance` dict and manufactured phantoms on
Earlgrey's generate-loop instance ARRAYS (`aes_sbox|work@aes_sbox_lut|16:5` is
43 golden instances against 80 of ours); the census now AGGREGATES every
instance behind a key into one bucket per side and reports the arity difference
as its own row (RESUME §9's census traps, both of them, paid for here).

**The coin did not flip.** `Scoreboard/default` is not in the mover set at all,
and every non-SimpleUVM head cmp log is byte-identical between the two binaries.

## 7. THE ATTRIBUTION

The order-blind sorted dump diff on both movers: **ADDED 8616, REMOVED 0** —
purely additive, nothing destroyed, re-spanned or re-typed. Because a new
parameter's dump block repeats field names that occur everywhere, the honest
attribution is at the OBJECT level, and every moved kind is then scored against
GOLDEN's own count:

```
kind                golden   pristine   patched    pris-gld   pat-gld
parameter              635        365       635       -270        +0
param_assign           410        230       410       -180        +0
constant             25716      23941     24201      -1775     -1515
ref_typespec         19364      18137     18583      -1227      -781
range                 1539        900       940       -639      -599
int_typespec          3022       2730      3038       -292       +16
ref_obj              41697      41694     41698         -3        +1
string_typespec       3302       3313      3361        +11       +59
```

`parameter` and `param_assign` land **exactly** on golden's count. Every other
moved kind moves TOWARD golden except `string_typespec`, which overshoots by 48
(R3). The 270 new `parameter` objects are placed, by `vpiParent`:

```
module_inst (DEF view)  work@top    0 -> 90    golden 90
module_inst (ELAB view) work@top    0 -> 90    golden 90
param_assign (the Lhs)            135 -> 225   golden 225
TOTAL parameter objects           365 -> 635   golden 635
```

## 8. THE HEAD AFTER — AND R0

```
SimpleUVM default and testflags, 664681 -> 62 cmp lines, ONE head each

LHS golden  constant: , id:119857, @26:39-26:82
            |vpiParent: \_param_assign: , id:119856, @26:18-26:82
            |vpiDecompile:"(C) 2007-2014 Mentor Graphics Corporation"
            |vpiSize:328
            |STRING:(C) 2007-2014 Mentor Graphics Corporation
            |vpiTypespec: \_ref_typespec: (work@top) -> string_typespec @26:11-26:17
            |vpiConstType:6
RHS ours    the SAME constant, the same decompile, the same value, the same
            typespec chain — with NO `vpiSize` line at all.
```

**R0 — a MATERIALIZED STRING PARAMETER'S CONSTANT CARRIES NO `VpiSize`.** The
head is now inside the population this law created, one field deep:
`uvm_version.svh:26`'s `uvm_mgc_copyright`, whose golden constant declares
`vpiSize` 328 (8 × 41 characters) while ours leaves it unset. `VpiSize` is read
by `expr::Compare` — `constant`'s BASE, at
`~/git-repos/UHDM/build/generated/src/expr.cpp:95`, ahead of every `constant`
field (verifier r10v196: `constant.cpp` itself never names `VpiSize`) — so this
is a one-field head on a face-identical pair — the
smallest kind. Six string parameters ride this road (`uvm_{mgc,cdn,snps,cy,nv}_copyright`,
`uvm_revision`); the sizing rule for a STRING constant under a
`string_typespec` is the whole question, and § 7's `string_typespec` overshoot
(R3) is its neighbour. The `uvm_pkg` PACKAGE listing's own copy of the same
parameter already agrees with golden, so the rule to read off is what the
MATERIALIZED copy does differently.

## 9. THE BOUNDARY AND THE FLOOR

```
LISTED=5189 PROCESSED=5189 PRODUCED_DBS=5018 MOVED_ARMS=53 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, PROCESSED is asserted
against LISTED). `grid196/g196_h_self.sv` is the POSITIVE CONTROL — a package,
a file-scope import and two modules in ONE file, so the gate, which compiles
each source alone, exercises this law; it IS in the moved list, and without it
a green gate would prove nothing.

**Each of the other 52 was rebuilt with a REAL Surelog golden in BOTH views and
scored** (`bscore196.sh`, 104 views, 0 unbuildable):

| arms | TO-GOLDEN | AWAY |
|---|---|---|
| `r10v146repro/*` (32 arms — the import family) + `r10uvm146repro/*` (6) | | |
| `r10uvm22/23/47/67`, `r10earl31/57/96`, `r10sd2`, `r10v76/159/164/168` | | |
| **all 52, 104 views** | **2440** | **0** |

Every one moves toward golden; none moves away; MOVED-WRONG 0.

**THE FLOOR IS UNTOUCHED**, verified by name in the moved list rather than
assumed:

```
uvm192 (4 arms)  uvm193 (4)  uvm184 (2, BOTH fences)  uvm194 (3)
uvm186 (3)  uvm189 (3)  uvm191 (3)  uvm185 (5)  uvm190 (4)  uvm187 (6)
uvm188 (4)  uvm170 (5)  uvm82-91 (113)  buvm3-15 (119)  sd8-12 (347)
34 families, 625 arms, MOVED = 0
```

No static-address false mover appeared: all 53 moved arms are accounted for by
content.

## 10. RESIDUES, ranked

* **R0 — the materialized string constant's `VpiSize`**, §8. The current head,
  both SimpleUVM modes, 62 cmp lines, one field.
* **R1 — `work@top`'s `Nets`, golden 225 vs ours 210.** A real difference on the
  same object, reached by `instance::Compare` right after the vectors this law
  fixed; it was BEHIND the head before and is still behind it now. It is the
  VARIABLE half of the same materialization family (`collectImportedPkgVars`),
  and the golden-only names are package variables carried twice
  (`build_ph`, `clp`, `uvm_top`, …). Not touched here.
* **R2 — the OURS-ONLY-COUNT 1392.** Pre-existing extra parameter copies on six
  rows (Earlgrey 1344, plus five small ones), identical before and after, all on
  rows the judge already calls CMP_EQUAL. The census `ARITY` rows show why: our
  generate-loop instance ARRAYS carry about twice golden's instance count, so
  the aggregated bucket carries twice the copies. A multiplicity family of its
  own; nothing here changes it.
* **R3 — the `string_typespec` / `int_typespec` overshoot**, §7: +48 and +16
  objects beyond golden's count. We mint a typespec per materialized copy where
  golden shares one. No generated `Compare` reads `VpiParent`, and the module's
  `Typespecs` listing is 123 = 123 before and after, so these objects sit in no
  compared vector and the judge cannot see them — but they are the neighbours of
  R0 and the two should be read together.
* **R4 — Earlgrey's `vpiImported` TAG residue**, §6: 14 cells in each mode where
  golden tags both copies of a `param_assign` lhs and we tag one.
  **CORRECTED BY THE VERIFIER (r10v196):** `parameter::Compare` DOES read
  `VpiImported` — it is the LAST field it compares
  (`~/git-repos/UHDM/build/generated/src/parameter.cpp:182`,
  `lhs->VpiImported().compare(rhs->VpiImported())`), after `VpiLocalParam` and
  `VpiName`. The residue is invisible today only because Earlgrey/testflags
  measures CMP_EQUAL and its default row's head fires earlier — NOT because the
  field is unread. Any future pass that moves a `vpiImported` tag must treat it
  as judge-visible. Recorded because a first cut of this pass's census mistook
  it for this law's population.
* **R5 — the arm-level nondeterminism.** Two runs of the SAME binary over the
  same 7-file arm set produced different bytes in the def view (RESUME §9's
  macro-buffer `SourceLocation` ordering under slang's parallel parse). Every
  arm verdict here is therefore taken from the CENSUS, never from a byte
  comparison of two runs.

## 11. THE FILES

| file | what it is |
|---|---|
| `ct196own.cpp` | the OWNER-FINDER: the design-level head, the parent-chain probe, the child descent, the failing FIELD (generic, through `GetByVpiType`), and the LOCATOR that answers "which listing, which index" by POSITION — the tool that refuted the brief's framing |
| `ct196chase.cpp` | the JUDGE CHASER: descends through LINKS as well as containment, and `--headowner` dumps the head object's own edges against its counterpart — where the `Parameters` NULL becomes visible |
| `ct196pop.cpp` | the INSTANCE-POPULATION census: every listing `scope::Compare` and `instance::Compare` walk, IN THEIR OWN COMPARE ORDER, plus the element face lists |
| `ct196imp.cpp` | the MATERIALIZED-IMPORT LISTING PRINTER: `Parameters` and `Param_assigns` in VECTOR ORDER with `vpiImported`, `vpiLocalParam`, the typespec and the right side's value — the tool the golden order tables come from |
| `ct196cen.cpp` | the CENSUS and MOVER PREDICTOR: `--cen` (golden × ours, aggregated per instance key, TWO joins), `--pred` (ours-only), `--obj` (whole-database object kinds) |
| `predict196.sh` / `cen196.sh` | the two corpus predictors; `cen196.sh` finds each row's golden through that row's OWN `cmds.txt` |
| `grid196.sh` / `grid196/` | the arm driver (a LIST of files per arm — a file-scope import cannot be tested from one source) and the eight arms |
| `attrib196.sh` | the order-blind dump diff + the object-kind attribution |
| `bound196.sh` / `bscore196.sh` | the wide boundary gate and the scorer that rebuilds every moved arm against a REAL Surelog golden |
| `scrub196.sh` | redacts the slang-fenced names out of the evidence, reading the list out of `canaudit.sh` |
| `DECODE.*` `ORDER.golden.*` `CENSUS.*` `GRIDS.*` `PREDICT.*` `MOVERS.*` `BOUNDARY*.*` `GATES.*` `head_{pris,pat}_*.cmp` | the evidence. The pristine SimpleUVM cmp logs are 664681 lines / 32 MB each and are committed as their first 40 lines with the full md5 — the count is the head object's decompile size, not a distance |

## 12. REPRODUCING

```sh
g++ -O2 -std=c++17 ct196<X>.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct196<X>
ct196own   <golden> <ours>                    # the head, the descent, the listing locator
ct196chase <golden> <ours> --headowner        # the head object's own edges
ct196pop   <golden> <ours> top --lists        # the population, in Compare order
ct196imp   <db> <tag> [name]                  # the ordered listings
CEN=./ct196cen ./predict196.sh <pristine wd> PREDICT.txt
CEN=./ct196cen ./cen196.sh     <wd> CENSUS.txt
IMP=./ct196imp CEN=./ct196cen ./grid196.sh <name> <pris> <patched> <wd> grid196/*.sv
CEN=./ct196cen ./attrib196.sh <patched wd> <pristine wd> <outdir> <rel...>
PRIS=… PATCHED=… ./bound196.sh <copy of tools/probe> <outdir>
PRIS=… PATCHED=… CEN=./ct196cen ./bscore196.sh <arms root> <outdir>/MOVERS <scoredir>
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <wd> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
bash canaudit.sh canaries.sh ctcan2.sh
```
