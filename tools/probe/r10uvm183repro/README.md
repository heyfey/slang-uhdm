# r10uvm183 — § `cloneForeachArrayRefUnresolved183` — **A WILDCARD-IMPORT CLONE'S FOREACH ARRAY REFERENCE IS UNRESOLVED IN BOTH PACKAGE VIEWS, AND ITS PLACEHOLDER KEEPS THE HOME PACKAGE** — the MiniAmiq ×2 26-line head CLEARED

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
| BASE | `6fee5084` |
| pristine binary | md5 `86973e02d6a070958700f9a63ffe3ffe`, built from this pass's OWN worktree at a clean `6fee5084` and frozen `chmod 555` before any sweep — **byte-identical to the master's own frozen pristine at that commit** |
| patched binary | md5 `646ee5730fe19d8d40576d9a2267aef0`, frozen `chmod 555` |
| production surface | `src/StmtEmit.cpp` ONLY — one disjunct on `foreachUnres9` and the import-copy instance link on the arm's two `unsupported_typespec` mints |
| probe surface | `tools/probe/r10uvm183repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **MiniAmiq default and testflags, 26 cmp lines, ONE head each → 13**, the two modes' logs BYTE-IDENTICAL before (md5 `32a37b37f74e…`) and after (md5 `6a7b1478c978…`). A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **4 / 956** surelog — **all four PREDICTED BY NAME, by TWO INDEPENDENT PREDICTORS THAT AGREE, before the patched sweep ran**, from the 956 PRISTINE databases and their goldens alone (`predict183.sh` / `predict183.py`, §5). **0 / 1358** uhdm2rtlil. |
| the corpus population | the `foreach` ARRAY REFERENCE of every package-level subroutine a package WILDCARD-IMPORTS. Over the four clone row-modes: **522 placeholder cells per row-mode, agreeing with golden 0 → 522** (2 by KIND, 520 by INSTANCE). |
| the census (nine UVM DBs × both modes) | **DEGRADE-TOWARD 1044 keys, MUST-STAY-AWAY 0, TOWARD-OTHER 0, MOVED-WRONG 0, untouched 5853.** Golden-vs-golden calibration first: **0 disagreements, 0 phantom cells**. |
| the grid (6 arms, both views, one REAL Surelog golden each) | on the KIND projection the law's degrade half owns: **TOWARD 52, AWAY 0, MOVED-WRONG 0**. On the INSTANCE projection: **TOWARD 56, TOWARD-PARTIAL 8, AWAY 0, MOVED-WRONG 0**. On the COPY-COUNT projection the law must not touch: **unchanged in every arm, both views**. Arm D (**no import anywhere**) is BYTE-IDENTICAL under both binaries in both views. |
| the WIDE boundary (4990 arms, both views) | `LISTED=4990 FENCED_SKIPPED=0 PROCESSED=4990 PROCESSED-ASSERT-OK`, **MOVED 24 arms / 48 arm-views**. **EVERY moved arm was re-built against its OWN REAL SURELOG GOLDEN in both views and scored in both columns: TOWARD 406, TOWARD-PARTIAL 14, AWAY 0, MOVED-WRONG 0, copy-count unchanged** (`BOUNDARY_MOVED_SCORES.r10uvm183.txt`). Two of the 24 hold NO `foreach` at all and are r10uvm154's already-decoded ADDRESS-DERIVED residue, re-confirmed to the digit (§8). |
| what the boundary CAUGHT | the wide gate is why this law has a fence: `r10v178repro/v178_f_shadow.sv` iterates a package PARAMETER inside a clone, golden RESOLVES it, and the first cut degraded it. The producer says why (`CompileType.cpp:750-762`), arm F now pins it, and the corpus is untouched either way (the same 4 movers, byte for byte, before and after the fence). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `6fee5084` worktree; it
came out byte-identical to the master's frozen pristine (`86973e02…`), its
23/23 goldens pass, and its own 956-row surelog sweep reproduces the committed
baseline row for row (`ct8rows` 0 differing rows over 1588, status AND dump
column).

`rowheads.sh` on that sweep — the numbers the brief named, confirmed:

```
TEST           MODE      CMPLINES  HEADS
MiniAmiq       default         26      1
MiniAmiq       testflags       26      1     (logs byte-identical)
SeqDriver      ×2              13      1
SimpleUVM      ×2          664681      1
Scoreboard     default         95      1
BuildUVMPkg    ×2              52      1
Earlgrey_0_1   default/tf   31 / 364    1
Rggen          default    CMP_EQUAL
```

The head (`head_pris_MiniAmiq.*.cmp`):

```
LHS golden  unsupported_typespec: (arg), line:622:11, endln:622:14
            |vpiParent \_ref_typespec: (svaunit_pkg::uvm_has_wildcard::arg)
            |vpiName:arg   |vpiInstance \_package: uvm_pkg
RHS ours    string_typespec: , line:614:42, endln:614:48
            |vpiInstance \_package: uvm_pkg
```

## 2. DECODING THE JUDGE FIRST — `ct183own`, AND THE BRIEF'S FRAMING REFUTED

The brief called this "golden's **formal** typespec on the svaunit_pkg clone of
`uvm_has_wildcard`". **It is not the formal.** `ct183own --refs --sharers`
(the mirror owner-finder, linking the SAME generated `Compare` the judge does,
with the referrer index built from the committed `r10ladder1repro/ctfields.inc`
field order) reads:

```
HEAD LHS(golden) = unsupported_typespec(arg)@uvm_misc.svh:622:11-622:14 #120949
  owner chain  < ref_typespec  < ref_var(arg)@622:11  < foreach_stmt@622:3
               < begin@618:3   < function(uvm_has_wildcard)@614:1
               < package(svaunit_pkg)@svaunit_pkg.sv:24:1  < design
  GOLDEN referrers: 1   (.Actual_typespec of that one ref_typespec)

HEAD RHS(ours)   = string_typespec()@:614:42-614:48 #182950
  OURS referrers: 2     .Actual_typespec of ref_typespec < io_decl(arg)@614:49
                        .Actual_typespec of ref_typespec < ref_var(arg)@622:11
                                                          < foreach_stmt@622:3
```

So the two spans are **the use site against the declaration site**:

* golden's `622:11` is the identifier `arg` inside `foreach(arg[i])` — the
  FOREACH's ITERATED REFERENCE, minted per site;
* our `614:42` is the `string` keyword of `function automatic bit
  uvm_has_wildcard (string arg);` — the FORMAL's own typespec object, which we
  **SHARE** between the io_decl and the foreach reference (that is what the two
  referrers prove, and it is § `foreachFormalArrayTs9` doing exactly what it was
  measured to do in the HOME package).

The formal's own `io_decl` is EQUAL on both sides in all four copies
(`string_typespec@614:42` each) — the tool prints them beside the foreach sites
(`--foreach=uvm_has_wildcard`), and so are all four LOOP VARIABLES. The whole
head is the ARRAY REFERENCE's typespec edge.

The four copies of the one source line, before:

| copy | golden ARR typespec | ours |
|---|---|---|
| `uvm_pkg` ELAB (home, `writePackage`'s copy) | `string_typespec@614:42` | same ✔ |
| `uvm_pkg` DEF (home twin) | `unsupported_typespec(arg)@622:11`, INST `uvm_pkg` def copy | same ✔ |
| `svaunit_pkg` clone, copy 1 | `unsupported_typespec(arg)@622:11`, INST **`uvm_pkg` ELAB** | `unsupported_typespec`, INST `svaunit_pkg` ✗ |
| `svaunit_pkg` clone, copy 2 | `unsupported_typespec(arg)@622:11`, INST **`uvm_pkg` ELAB** | **`string_typespec@614:42`** ✗ ← THE HEAD |

The ablation (seeding the golden head into a fresh `CompareContext`'s
`m_visited`, the LHS-keyed early-out every generated `Compare` opens with)
moves the judge straight to `func_call(max)` under `hier_path(q.max)` at
`uvm_printer.svh:1054:12` with `RHS <null>` — which is R0, and is what the
patched database then measures (§9).

## 3. DECODING SURELOG — THE DEGRADE WINDOW, PER FACE

### 3.1 The mechanism

`compileStmt`'s `paFOREACH` case hands the loop list's array identifier to
`compileVariable` (`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp:527-530`):

```cpp
UHDM::any* var = compileVariable(
    component, fC, fC->Child(Ps_or_hierarchical_array_identifier), …);
```

For a BARE name that lands in `compileVariable`'s `slStringConst` arm
(`CompileType.cpp:250-430`). The typespec is computed FIRST, from the NAME
itself (`:317-330`, `ts = compileTypespec(component, fC, declarationId, …)`),
which for an identifier that is no type falls out of
`compileDatastructureTypespec`'s tail as an `unsupported_typespec` **named as
written, at the identifier's own span**. Every lookup in the arm then misses,
and the fall-through at `:421-430` mints

```cpp
ref_var* ref = s.MakeRef_var();
… tsRef->Actual_typespec(ts);
if (ts->UhdmType() == uhdmunsupported_typespec)
    component->needLateTypedefBinding(ref);      // :428
ref->VpiName(typeName);
```

So **the placeholder is what EVERY listing holds** until one later pass
rewrites it. That pass is `UhdmWriter::lateTypedefBinding`, and `writePackage`
runs it over the **home package's ELABORATED copy alone**
(`UhdmWriter.cpp:1301` — the same fact § `foreachArraySelfSelectAssignDropsTs19`
already reads through, and the same `swapForSpecifiedVar` machinery
§ `classPropUnitImport21` decodes for the LOOP VARIABLE).

An IMPORT COPY is never that copy: it re-uses the home's un-elaborated body
whichever listing it lands in. Hence the window.

### 3.2 The window, measured on real Surelog goldens (`g183_a_homes.sv`, both views)

| listing | golden's foreach ARRAY-REFERENCE typespec | its `vpiInstance` |
|---|---|---|
| home package, **ELABORATED** copy | **RESOLVED** (`string` / `array` / `int` typespec) | the home package (or none) |
| home package, DEF copy | **`unsupported_typespec` named as written** | the home package's DEF copy |
| **WILDCARD-import clone**, BOTH copies | **`unsupported_typespec`** | **the HOME package, ELABORATED** |
| **EXPLICIT named-import copy**, BOTH copies | **`unsupported_typespec`** | **the HOME package, ELABORATED** |
| MODULE that imports and hoists the body | **RESOLVED** | as the home |
| class method (in-body or out-of-body) | `unsupported_typespec` | none — unchanged, § `classPropArr9` owns it |

and the answer does **not** depend on the ITERATED OBJECT's home: a FORMAL, a
subroutine LOCAL, a STATEMENT-BLOCK local, a PACKAGE-level variable and a
`task`'s `ref` formal all degrade together in a clone (arm A: `cnt_fml`,
`cnt_loc`, `cnt_blk`, `cnt_pkgvar`, `tsk_fml`), which is why the gate sits
ABOVE the formal/local resolution rather than inside it.

### 3.3 The DECLARED-KIND axis — the row that fenced uvm170 does NOT fence this one

r10uvm170's law had to be re-cut because its degrade depended on what the
typedef was WRITTEN as. This face does not: `g183_b_kinds.sv` puts eight
declared kinds through the same clone —

| kind | clone answer |
|---|---|
| `string sq[$]` (formal) · `int fixed_five[5]` · dynamic `lvl_e steps[]` · packed-struct queue · `typedef int quad_t[4]` alias · associative `[string]` · associative `[int]` · 2-D `bit[3:0] grid_it[2][3]` | **`unsupported_typespec` in every one** |

— TOWARD 8 (def) / 16 (elab) on the KIND projection, AWAY 0. The mechanism
explains it: the placeholder is minted from the NAME before any type is
consulted, so nothing about the declaration can change it.

### 3.4 The DPI-ADJACENCY axis — a DIFFERENT window from uvm170's

`g183_c_window.sv` writes `export "DPI-C"` ABOVE, BELOW and NOWHERE around
three otherwise identical functions with a `foreach`, in a home package and its
wildcard clone. All three degrade in the clone and all three resolve in the
home's elaborated copy: **the `export "DPI-C"` position does not enter this
face at all** (TOWARD 4 def / 8 elab, AWAY 0). § `dpiExportedPkgSubBareOwnTdUnsupported170`'s
window is the FUNCTION-vs-DEFINITION collect pass; this one is
`lateTypedefBinding`'s single listing. Two windows, two mechanisms, no overlap.

### 3.5 The INSTANCE half

Golden stamps the placeholder's `vpiInstance` with the **HOME** package inside
an import copy — the ELABORATED home copy, on the corpus and on the arms alike
— and with the emitting package's own copy in the home package's own DEF view.
Measured, not assumed: over the four clone row-modes golden has **522 cells
stamped `uvm_pkg` and 0 stamped `svaunit_pkg` / `adpcm_pkg`**, while we had 520
stamped the IMPORTING package. This is § `scopedTdUnsupTsHomePkgInstance83`'s
and § `builtinClassLocalUnsupportedBeforeClassPhase115`'s rule on a new site,
and it uses those laws' own pointer.

## 4. DECODING SLANG — THE GATE, AND WHY IT IS ONE LINE

`src/StmtEmit.cpp`'s `ForeachLoop` arm already computed

```cpp
bool foreachUnres9 = classMethodNoBind || pkgDefViewBody9 || classPropArr9;
```

`pkgDefViewBody9` is the DEF listing of a package body, so a clone's DEF copy
already degraded; its ELABORATED twin fell through to the resolved arm. The
LOOP-VARIABLE half of the same question had already been closed —
§ `cloneForeachLoopVarUnresolved37` names `pkgImportCloneEmit` as the listing
test in a comment eighty lines below, *"the importer's ELABORATED listing of a
cloned FREE function fell through to the resolved arm … the clone re-uses the
home's UN-elaborated body whichever listing it lands in"* — and the ARRAY
REFERENCE was simply left behind. So the degrade half is that same disjunct:

```cpp
bool foreachUnres9 = classMethodNoBind || pkgDefViewBody9 ||
                     classPropArr9 || pkgImportCloneEmit;
```

The INSTANCE half is the committed import-copy idiom, applied to the two
`unsupported_typespec` mints this arm owns (the bare-name one and
§ `foreachScopedArrayWrittenClassVar33`'s `::`-scoped one, which is the SAME
object in golden's eyes):

```cpp
if (auto* ui183 = importCopyTsInst ? importCopyTsInst : pkgScopeInst)
    uts->Instance(ui183);
if (importCopyTsInst && importCopyTsCollect)
    importCopyTsCollect->push_back(uts);
```

`importCopyTsInst` is set by the clone driver in `ParamEmit.cpp` for the whole
`emitTaskFuncs` of an import copy, and `importCopyTsFixups`
(`UhdmExporter.cpp` ~5033, *"Import-clone typespecs point vpiInstance at the
ELABORATED (top) home package, which only exists now that the top views are
built"*) re-points every collected typespec once the top views exist — which is
exactly the copy golden names. Nothing else in the file changed; the arm's
`arrThis21`, `dropArrTs19`, `arrMember9` and `scopedArr33` branches keep their
precedence, so an unlisted shape can only cost this law a cell, never move one
off golden.

## 5. THE A-PRIORI PREDICTION — MADE FIRST, FROM PRISTINE DATABASES ONLY

`predict183.sh` walks all **956** comparable rows of the pristine sweep, reads
each row's OWN `cmds.txt` for its golden cache path, and dumps the foreach
census of both. `predict183.py` then applies **two independent predictors** and
requires them to agree:

* **OURS-SIDE** (the law's own shape): a row moves iff our pristine database
  lists one `foreach` key under **two or more different PACKAGE scopes** — one
  source line in two packages is a wildcard-import clone and nothing else.
* **GOLDEN-SIDE**: a row moves iff golden holds a package-scope foreach
  array-reference `unsupported_typespec` whose `vpiInstance` package differs
  from its own enclosing package, and our multiset lacks that exact cell.

```
comparable rows=956
OURS-SIDE   predicted moving rows=4
GOLDEN-SIDE predicted moving rows=4
AGREE=True
  MOVER default   MiniAmiq   clone-foreach-keys=304  golden-clone-cells=522
  MOVER default   SeqDriver  clone-foreach-keys=304  golden-clone-cells=522
  MOVER testflags MiniAmiq   clone-foreach-keys=304  golden-clone-cells=522
  MOVER testflags SeqDriver  clone-foreach-keys=304  golden-clone-cells=522
```

The byte gate returned **exactly those four and nothing else** (4 / 956;
0 / 1358 on uhdm2rtlil), `PATH_SETS_IDENTICAL`, `SELFCHECK` 955/956 and
1357/1358. The script asserts a nonzero comparable-row count, because a
predictor that reaches nothing must never read as "no movers".

## 6. THE CORPUS CENSUS — NINE UVM DBs × BOTH MODES, BOTH COLUMNS

`cenrun183.sh` + `join183.py`, keyed on `(line:col, enclosing subroutine)` with
the FILE stripped from every span (our objects carry an empty `vpiFile`,
Surelog's carry a path — a key with the file joins nothing) and per-database
`UhdmId`s stripped, value = the MULTISET of `(array object, array typespec,
instance)` — a multiset join, never a dict.

**Calibrated golden-vs-golden FIRST: `untouched=6897, degrade-cells=0`** — the
join manufactures no phantom.

```
rows=9
  DEGRADE-TOWARD  1044     (golden degrades, pristine resolved or mis-stamped, patched == golden)
  TOWARD-OTHER       0
  MUST-STAY-AWAY     0     <-- the reverse column: NOT ONE golden-RESOLVED site went unsupported
  MOVED-WRONG        0
  untouched       5853
```

`CENSUS_AGG.r10uvm183.txt` gives the same thing per row-mode as a
golden | pristine | patched table over `(owning scope, array typespec kind,
instance package)`; every clone row goes to full agreement:

| row-mode | cell | golden | pristine | patched |
|---|---|---|---|---|
| MiniAmiq ×2 | `package:svaunit_pkg unsupported_typespec @uvm_pkg` | 522 | 0 | **522** |
| | `package:svaunit_pkg unsupported_typespec @svaunit_pkg` | 0 | 520 | **0** |
| | `package:svaunit_pkg string_typespec @uvm_pkg` | 0 | 1 | **0** |
| | `package:svaunit_pkg array_typespec` | 0 | 1 | **0** |
| SeqDriver ×2 | the same four rows over `adpcm_pkg` | 522 / 0 / 0 / 0 | 0 / 520 / 1 / 1 | **522 / 0 / 0 / 0** |
| BuildUVMPkg ×2, SimpleUVM ×2, Scoreboard | — | | | **no cell moved** |

The two KIND cells per clone row-mode are named: `uvm_has_wildcard`'s FORMAL
(`foreach (arg[i])`, uvm_misc.svh:622 — the head) and `uvm_string_to_action`'s
SUBROUTINE LOCAL (`foreach (actions[i])` over `string actions[$]`,
uvm_globals.svh:288). The other 520 are the INSTANCE half.

The reverse (must-stay) column corpus-wide is stronger than a census: the byte
gate proves **952 of 956 surelog databases and all 1358 uhdm2rtlil databases
are byte-identical** under the two binaries, so no foreach cell in any of them
can have moved at all.

### 3.6 The ONE shape a clone still RESOLVES — the PARAMETER, and the fence

`g183_f_param.sv` and `r10v178repro/v178_f_shadow.sv` both show it: inside a
wildcard clone golden RESOLVES a `foreach` over a package **parameter** or
**localparam** — `parameter int P_ROWS[0:3]` → `array_typespec()@14:14`,
`parameter trio_t P_TRIO` → `array_typespec(trio_t)@12:11` — while a package
**variable** of the same shape in the same clone degrades
(`int v_slots[4]` → `unsupported_typespec(v_slots)@36:14`).

The producer says why, and it is not the placeholder path at all: before
`compileDatastructureTypespec` falls out to the placeholder it scans
`component->getParamAssignVec()` for a `param_assign` whose LHS parameter
carries this name and returns that parameter's own `Actual_typespec`
(`CompileType.cpp:750-762`). A package's parameters are collected before its
subroutines are compiled, so the answer is the same in every listing, clone
included. The law is fenced on exactly that (§4), the fence has **zero corpus
cells** (the four movers are byte-identical with and without it), and arm F is
the positive-and-negative pair that pins it in one file.

## 7. THE GRID — 6 ARMS, BOTH VIEWS, ONE REAL SURELOG GOLDEN EACH

`grid183.sh` builds one Surelog golden and both frozen binaries' databases in
both views and records every rc (an rc=139 segfault must never read as a
result); `score183.py` scores three projections per foreach site — KIND (the
field the degrade half owns), INST (the field the instance half owns) and the
COPY COUNT, which the law must not touch.

| arm | axis | sites (def/elab) | KIND TOWARD/AWAY/WRONG | INST TOWARD/AWAY/WRONG | CNT |
|---|---|---|---|---|---|
| `g183_a_homes.sv` | home listing × wildcard clone × explicit-import copy × module hoist × class method, over formal / local / block-local / package var / task | 14 / 20 | **5 / 0 / 0** and **5 / 0 / 0** | **6 / 0 / 0** (+1 TOWARD-PARTIAL) ×2 | unchanged |
| `g183_b_kinds.sv` | eight DECLARED KINDS through one clone | 16 / 24 | **8 / 0 / 0**, **16 / 0 / 0** | **8 / 0 / 0**, **15 / 0 / 0** | unchanged |
| `g183_c_window.sv` | `export "DPI-C"` ABOVE / BELOW / NONE × clone | 8 / 12 | **4 / 0 / 0**, **8 / 0 / 0** | **4 / 0 / 0**, **8 / 0 / 0** | unchanged |
| `g183_e_shapes.sv` | bare / `this.` / dotted / `::`-scoped / out-of-body / package-var spellings inside a clone | 9 / 11 | **1 / 0 / 0**, **2 / 0 / 0** | **2 / 0 / 0**, **4 / 0 / 0** | unchanged |
| `g183_f_param.sv` | THE FENCE: package parameter / localparam / typedef'd-array parameter against a package VARIABLE, in one clone | 8 / 12 | **1 / 0 / 0**, **2 / 0 / 0** | **1 / 0 / 0** (+3 TOWARD-PARTIAL) ×2 | unchanged |
| `g183_d_noimport.sv` | **NEGATIVE CONTROL** — no import anywhere | 5 / 6 | **0 / 0 / 0** | **0 / 0 / 0** | unchanged |

Arm D's two databases are **byte-identical** under the two binaries in both
views, and arm D did not appear in the wide boundary's moved list either.

**The one TOWARD-PARTIAL cell**, in both views of arm A: `cnt_blk`'s
`inner_row` in the EXPLICIT-import copy `expl183`. Golden stamps the home
package on both of that copy's listings; pristine stamped `expl183` on one and
nothing on the other; patched stamps the home package on one and still nothing
on the other. Strictly closer, nothing that already matched lost — the scorer
gives that its own column rather than calling an improvement a regression, and
the residue that keeps it short is R2.

`stilloff183.py` lists every cell that disagrees with golden identically under
BOTH binaries (an arm that only reports what moved hides what it failed to
move). They are named in §11 as R1–R3; not one of them is a cell this law
moved.

## 8. THE WIDE BOUNDARY — 4990 ARMS, BOTH VIEWS

Run from a COPY of the whole `tools/probe` tree so no path filter can hide an
arm; subdirectory arms included; the file list read on fd 3, children
`</dev/null`, `PROCESSED` asserted against `LISTED`, scratch keyed on the
RELATIVE path (`bound183.sh`, reused verbatim from `r10uvm181repro`).

```
LISTED=4990  FENCED_SKIPPED=0  PROCESSED=4990  MOVED=48 arm-views (24 arms)
PROCESSED-ASSERT-OK      NO_OUTPUT_PAIRS=380 (identical on both binaries)
```

**A moved arm is not a regression and a still arm is not a proof — so every one
of the 24 was re-built against its OWN REAL SURELOG GOLDEN, in both views, and
scored in BOTH columns** (`BOUNDARY_MOVED_SCORES.r10uvm183.txt`, produced by
`grid183.sh` + `score183.py` over the boundary's own copies):

```
24 arms × 2 views:  TOWARD 406   TOWARD-PARTIAL 14
                    AWAY 0   MOVED-WRONG 0   MOVED-SIDEWAYS 0
                    copy-count projection unchanged in every arm
```

| moved arms | verdict |
|---|---|
| `r10uvm183repro/g183_{a,b,c,e,f}*.sv` (5) | **this pass's own arms — the POSITIVE CONTROL** (a gate that reported zero over them could not see). Scored in §7. `g183_d_noimport.sv`, the negative control, is NOT in the moved list. |
| `r10uvm181repro/g181_{a_kinds,b_dims,c_home,d_negatives}.sv`, `r10v181repro/v181_{a_use,b_prefix,c_homes,e_idxbase,f_mixed,g_scopes}.sv`, `r10uvm180repro/g180_b_depth.sv`, `r10uvm37repro/t51{a,b}_dut.sv`, `r10uvm21repro/t32d/t.sv`, `r10buvm19repro/grid19.sv`, `r10vbuvm19repro/vg19c.sv`, `r10v178repro/v178_f_shadow.sv` (18) | **the CLONE-FOREACH neighbourhood — this law's own subject, and the must-stay floor the brief names.** They move because they are arms about exactly this construct (§ `cloneForeachLoopVarUnresolved37`'s `t51a`/`t51b`, § `cloneLoopVarShared37`, uvm181's clone-binding arms, buvm19's `imp19` import-clone cells). Scored against real goldens: e.g. `grid19.sv` **KIND TOWARD 5 / INST TOWARD 23**, `g181_b_dims.sv` **12 / 12** both views, `g181_a_kinds.sv` **9 / 9**, `v181_c_homes.sv` **16 / 16**. **AWAY 0 and MOVED-WRONG 0 in all eighteen, both views, both columns.** |
| `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` (2) | **R-addrbound**, r10uvm154's already-decoded ADDRESS-DERIVED residue, re-confirmed to the digit: the class-scoped `typedef <T> name[string]` range bound reads `22609657` / `22608801` under the pristine binary and `22605561` / `22604705` under the patched one — a shift of **exactly 4096** against a **4144-byte binary SHRINK** (22 423 200 → 22 419 056). Both arms contain **no `foreach` at all** (`grep -c foreach` = 0) and their foreach census has **0 sites**, so this law's mints are provably unreachable in them. |

Every committed arm of r10uvm170 (its five `g170_*` arms and both its fences),
of uvm82–91, of buvm3–15 and of sd8–12 is **byte-identical under both binaries
in both views** — none of them is in the moved list at all.

**THE ONE CELL THE BOUNDARY CONVICTED.** The first cut had no parameter fence,
and `r10v178repro/v178_f_shadow.sv`'s `Beta_imp_F::f_foreach` over `parameter
int arr_p [0:3]` scored **MOVED-SIDEWAYS** on the KIND column: golden resolves
both clone copies, pristine resolved one, the first cut degraded both. The
fence (§3.6, §4) was written from the producer, arm F was added to pin it, and
the re-run scores that cell **still-off on KIND, TOWARD-PARTIAL on INST** —
nothing left the intersection with golden. The corpus never saw either version:
the four movers are byte-identical, hash for hash, before and after the fence.

## 9. THE GATES, IN ONE LINE EACH

* Build: pristine `86973e02d6a070958700f9a63ffe3ffe` (byte-identical to the
  master's frozen pristine at `6fee5084`), patched
  `646ee5730fe19d8d40576d9a2267aef0`; both frozen `chmod 555` before any sweep,
  and **every gate below was re-run end to end on the FENCED binary** — the
  pre-fence numbers are not carried forward.
* Goldens: **23 PASS / 0 FAIL** patched, **23 / 0** pristine, **0 PASS /
  23 FAIL** with `SLANG_UHDM=/bin/false` (the negative control), `SLANG_UHDM`
  exported explicitly to each binary.
* uhdm2rtlil: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in both
  modes under both binaries; `ct8rows` **0 differing rows** against the
  committed `results/gate_uhdm2rtlil.csv` AND against this pass's own pristine
  sweep, BOTH modes, status AND dump column; `byteverify SELFCHECK=1`
  **0 movers / 1358**, `PATH_SETS_IDENTICAL`.
* surelog: default `471 / 283 / 25 / 10 CMP_NOTEQUAL / 5 DEFERRED`, testflags
  `466 / 284 / 23 / 9 / 5 / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT /
  1 NO_UHDM` — **identical to this pass's own pristine sweep cell for cell**;
  `ct8rows` **0 differing rows over 1588** against the committed baseline and
  against the pristine sweep; **NO ROW CONVERTED**.
* cmds.txt audit: every `cmds.txt` in all four sweeps names the intended
  FROZEN binary by PATH; the only files without it invoke no slang binary at
  all (golden-cache-only rows) — checked by path, not by the string
  `slang-uhdm`, which also matches `slang-uhdm-goldens/`.
* Bytes: **4 movers / 956**, exactly the four both predictors named from
  pristine databases before the patched binary existed.
* Attribution (`attrib183.sh`, workdir-normalised, `id:`-stripped, plain AND
  ORDER-BLIND): each of the four movers' sorted dump diff contains **only** this
  law's own lines — 522 `\_package: uvm_pkg` in, 520 `\_package: svaunit_pkg`
  (`adpcm_pkg`) out, 2 `|vpiInstance:` in, and the four lines of the two KIND
  conversions (`\_unsupported_typespec: (arg)` + `|vpiName:arg` and the same
  for `(actions)` in; `\_string_typespec` and `\_array_typespec` out). Nothing
  else. Scoreboard/default, the known ~50/50 COIN, did not move at all.
* Canaries: `canaries.sh` **ok=52 changed=0** (surelog) and **ok=8 changed=0**
  (u2r); `ctcan2.sh` PASS with `EXPECT_UNKNOWN=1` and `=6`; `canaudit.sh`
  **29 audited, 0 UNCOVERED, 0 FENCE-BREACH**.
* Byte pins: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical to the
  pristine sweep, in BOTH modes.
* Heads after (`rowheads.sh`): **MiniAmiq 13 / 13** (the two modes' logs
  byte-identical, md5 `6a7b1478c978…`); SeqDriver **13 / 13**, SimpleUVM
  **664681 / 664681**, Scoreboard/default **95**, BuildUVMPkg **52 / 52**,
  Earlgrey **31 / 364**, Rggen/default CMP_EQUAL — all unchanged.

## 10. R0 — THE NEXT HEAD ON THE MiniAmiq ROW

**MiniAmiq default and testflags, 13 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** — and it is the SAME OBJECT SHAPE as the SeqDriver row's
standing head:

```
uvm_printer.svh:1054   qq = q.max;        (uvm_table_printer::emit)
LHS golden  func_call (max)  |vpiParent \_hier_path (q.max)@1054:12-1054:17
RHS ours    <null>
site: svaunit_pkg's clone of uvm_pkg::uvm_table_printer::emit, inside two begins
```

Golden appends a `func_call (max)` element to the `hier_path` for the BUILT-IN
ARRAY REDUCTION method read as a value and our `Path_elems` is one short, so
the vector SafeCompare sets the OWNER as LHS and leaves RHS unset (RESUME.md
§9). **This is the head r10uvm182 is dispatched on for SeqDriver** — the two
rows now share one family, and clearing it should clear both.

## 11. RESIDUES

* **R1 — the EXPLICIT-import copy's KIND cell (first-ranked).** Golden degrades
  the foreach array reference in BOTH listings of an EXPLICIT named-import copy
  too (`g183_a_homes.sv`, `package:expl183`, `cnt_fml`'s `wrds` and `cnt_blk`'s
  `inner_row`), and we degrade one listing and resolve the other — the very hole
  this pass closed for the WILDCARD path. It is NOT generalised here because
  `pkgImportCloneEmit` covers only the wildcard clones by design
  (§ `formalDefaultBindsLikeBody13` records the same split) and because the
  corpus population is **zero**: the byte gate moved four databases, all of them
  wildcard. The cells exist, are measured, and are listed by `stilloff183.py`;
  the generalisation is not made. The INSTANCE half of the same copy DID move
  toward golden (§7's one TOWARD-PARTIAL cell), because `importCopyTsInst`
  covers both copy paths.
* **R2 — the second explicit-copy listing's NULL instance.** In `expl183` one of
  the two listings carries no `vpiInstance` at all under both binaries where
  golden carries the home package. Independent of this law (present in
  pristine), and it is what keeps R1's cell at TOWARD-PARTIAL instead of TOWARD.
* **R3 — the NAMELESS / mis-spanned resolved `array_typespec`.** Where golden
  resolves a foreach array reference to `array_typespec()@40:12-40:23` (the
  DECLARATION's span, and `array_typespec(quad_t)@9:11` when the declaration
  names a typedef'd array type), we answer `array_typespec()@0:0-0:0`. Present
  identically on both binaries in arms A and B, and in the corpus it is the
  `class_defn:uvm_component` cell that stands in all NINE UVM row-modes
  (golden 4 `array_typespec` + 1 `string_typespec@uvm_pkg`, ours 5
  `array_typespec`; 6/2 on BuildUVMPkg). A separate naming/identity family.
* **R4 — MiniAmiq's INTERFACE foreach family.** 19 `interface_inst`-scope
  foreach array references where golden holds an `unsupported_typespec` and we
  hold 18 `array_typespec` + 1 `class_typespec` (svaunit's VPI interface).
  Present identically on both binaries; a MODULE/INTERFACE-listing question,
  not a package-clone one, and untouched here.
* **R5 — the associative-array declaration span.** Golden's resolved answer for
  `int by_word[string]` / `bit by_num[int]` is `array_typespec()` at the
  DECLARATION span; ours is at `0:0`. `g183_b_kinds.sv` `k_assoc_s` / `k_assoc_i`,
  both views, both binaries — the same family as R3.
* **R6 — Surelog's own `[ERR:EL0514] Undefined variable` on the `::`-scoped
  foreach.** `g183_e_shapes.sv:32`'s `foreach (Node183::statics[cc3])` makes
  Surelog emit that diagnostic (rc=4) while still producing the golden — it is
  the very miss § `foreachScopedArrayWrittenClassVar33` models. Recorded so the
  arm's rc is not read as a broken arm.
* **R7 — the PARAMETER's DEF-view listing.** Golden resolves a `foreach` over a
  package parameter in EVERY listing (§3.6); we still degrade it in the DEF
  listing of the home package and of the clone alike, because that cell belongs
  to § `pkgDefViewBody9`, not to this law, and widening a landed law over a
  construct with zero corpus population is not this pass's business. Measured on
  `g183_f_param.sv` (`sum_param` / `sum_localparam` / `sum_trio`, both views,
  both packages, identical under both binaries) and listed by `stilloff183.py`.
  Anyone widening it should reuse `arrIsParam183` and re-run arm F.

## 12. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct183own.cpp` | the OWNER-FINDER + judge decoder: owner chains, the referrer index (via the committed `r10ladder1repro/ctfields.inc`), `--sharers` (how many edges point at each side — how the SHARED formal typespec was told from golden's per-site mint), the `m_visited` ABLATION, `--maskall`, `--chain=N`, and `--foreach=<sub>` (every foreach of a named subroutine on BOTH sides with its iterated reference, that reference's typespec edge, every loop variable, and the subroutine's io_decls beside them). |
| `ct183cen.cpp` | the census reader: `--fe` (one TSV row per `foreach_stmt` — span, enclosing subroutine, OWNING SCOPE WITH ITS UhdmId so DEF and ELAB copies are distinct, the iterated object, its typespec, that typespec's `Instance`, and every loop variable), `--utsinst` (every `unsupported_typespec` with its `Instance`). |
| `grid183.sh` / `score183.py` / `stilloff183.py` | one Surelog golden + both binaries × both views per arm with every rc recorded; the three-projection scorer (KIND / INST / COPY-COUNT, with a TOWARD-PARTIAL column); the still-off lister. |
| `cenrun183.sh` / `join183.py` | the corpus census over a sweep workdir pair, with the DEGRADE-TOWARD and MUST-STAY-AWAY columns and a golden-vs-golden calibration mode. |
| `predict183.sh` / `predict183.py` | the A-PRIORI mover prediction from PRISTINE databases and goldens only, by TWO independent predictors required to agree; asserts a nonzero comparable-row count. |
| `attrib183.sh` | mover attribution: workdir-normalised, `id:`-stripped, plain AND order-blind dump diffs. |
| `bound183.sh` | the wide boundary gate over a COPY of the probe tree. |
| `g183_a_homes.sv` … `g183_f_param.sv` | the six grid arms (§7). |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the standard gate battery, copied unchanged. |
| `OWNER.*.txt` `OWNER_PATCHED.*.txt` `PREDICT.*.txt` `CENSUS.*.txt` `CENSUS_AGG.*.txt` `GRID.*.txt` `GRID_STILLOFF.*.txt` `BOUNDARY_MOVED_SCORES.*.txt` `MOVERS.*.txt` `GOLDEN_MATRIX_{a_def,a_elab,f_elab}.txt` `head_{pris,pat}_MiniAmiq.*.cmp` | the recorded outputs every number above was read from. |

## 13. REPRODUCING

```sh
g++ -O2 -std=c++17 ct183own.cpp -I ~/.local/include -I ../r10ladder1repro \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct183own
g++ -O2 -std=c++17 ct183cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct183cen

# the head, decoded (and the brief's framing refuted)
/tmp/ct183own <golden.uhdm> <ours.uhdm> --refs --sharers --chain=6 \
              --foreach=uvm_has_wildcard

# the grid
CT183CEN=/tmp/ct183cen ./grid183.sh g183_a_homes.sv <pristine> <patched> <wd>
python3 score183.py <wd> [--all]
python3 stilloff183.py <wd>

# the a-priori prediction (PRISTINE ONLY) and the census
PRIS=<pristine-workdir> CT183CEN=/tmp/ct183cen ./predict183.sh <out> 2
python3 predict183.py <out>
CT183CEN=/tmp/ct183cen ./cenrun183.sh <pris-wd> <pat-wd> <out> \
    'SeqDriver|SimpleUVM|Scoreboard|MiniAmiq|BuildUVMPkg'
python3 join183.py <out>            # add --pristine-only for the before picture

# attribution and the boundary
./attrib183.sh <pris-wd> <pat-wd> <out> 'SeqDriver|SimpleUVM|Scoreboard|MiniAmiq|BuildUVMPkg'
PRI=<pristine> PAT=<patched> ROOT=<copy-of-tools/probe> BWD=<wd> ./bound183.sh
bash canaudit.sh canaries.sh ctcan2.sh
```
