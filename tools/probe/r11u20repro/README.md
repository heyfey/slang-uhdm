# r11u20 — a type parameter's default range bound is never reduced, and a
# package-body call never lists on a module

Base `aa69cb57` (matrix-1.87).  Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.
Two laws landed.

**ONE TEST CONVERTS — say it plainly: `struct_param_field_shift` moves
`CMP_NOTEQUAL` -> `CMP_EQUAL` in BOTH modes.**  The committed baseline rows it
replaces are

```
results/gate_uhdm2rtlil.csv:739     struct_param_field_shift,testflags,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:739   struct_param_field_shift,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:1610  struct_param_field_shift,testflags,CMP_NOTEQUAL,decompile:,,
```

and this pass measures `struct_param_field_shift,<mode>,CMP_EQUAL,,,differ` in
both.  `results/*.csv` is UNTOUCHED by the patch; the promotion is the
integrator's to make.

`param_nested_struct_field_width` clears its head and advances onto a new one
(§6).  Five further corpus rows move, every one TO golden.

---

## 1. The two heads, RE-MEASURED at this base

Measured on this pass's own pristine build (md5
`0691f7273455a3628c2de8fcc773ef90`, byte-identical to the main tree at
`aa69cb57`), official `uhdm-cmp`, LHS always golden, ONE head per run, both
modes identical.

| test | pristine head | lines / heads |
|---|---|---|
| `param_nested_struct_field_width` | `operation` at `41:44-41:50`: golden keeps the `NLOG-1` bound of `localparam type sel_t = logic [NLOG-1:0]` as `vpiOpType:11` over `ref_obj (work@dut.sel_t.NLOG)` + `UINT:1`; ours is `constant UINT:3 sz 64 ct 9 vpiDecompile:NLOG-1` | 29 / 1 |
| `struct_param_field_shift` | `LHS: <null>` / RHS the ELABORATED `module_inst work@struct_param_field_shift` | 604 / 1 |

### The `struct_param_field_shift` head is NOT what the pointer said — REFUTED

The r11u18 write-up read this head as "an `array_var acc` that WE EMIT and
golden DOES NOT".  That is wrong in both halves, and the pristine databases say
so:

* golden's ELABORATED `module_inst` carries the identical `array_var acc`
  (`vpiSize:2`, `array_typespec`, range `0:1` with `UINT:0`/`UINT:1`, a `vpiReg`
  `logic_var` on the `logic_typespec` at `29:3-29:23`) — object for object ours;
* golden's DEFINITION `module_inst` carries `acc` as a COLLAPSED `logic_net`
  under `vpiNet` with the unpacked dimension dropped, and so does ours.  That
  collapse is Surelog's own documented behaviour
  (`UhdmWriter::writeNets`, `~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:895-905`:
  the extra definition-level `array_net` is emitted for an
  `uhdminterface_inst` parent ONLY).

The field that actually fails is `instance::Compare`'s **`Task_funcs`**
(`~/git-repos/UHDM/build/generated/src/instance.cpp:335`, immediately ahead of
`Nets()` at `:336`): golden's vector is **NULL**, ours holds ONE entry — the
package function `cfg_pkg::build_config`.  The vector `SafeCompare`'s
`(lhs == nullptr && rhs != nullptr && !rhs->empty())` branch sets
`m_failedRhs` to the **owner** and leaves `m_failedLhs` unset, which is exactly
how the whole module came to print under `LHS: <null>`
(`~/.local/include/uhdm/BaseClass.h:216-221`).  Comparing the two elaborated
modules' top-level field lists shows the single extra `|vpiTaskFunc:` and
nothing else.

---

## 2. § typeParamDefaultBoundNoReduce20 — the producer and its key

A type parameter's typespec is compiled from its DECLARATION DEFAULT with
**`Reduce::No` and a null instance**:

```
CompileHelper::compileParameterDeclaration
  ~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3475-3476
      (paList_of_type_assignments — the ANSI parameter-port-list arm)
  ~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3509-3510
      (paTYPE — the body / non-ANSI / package / class arm)
  ~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3554-3555
      (the packed-dimension continuation of the same arm)
    compileTypespec(component, fC, ntype, compileDesign, Reduce::No, p,
                    nullptr, false)
```

So no bound of that type is ever folded, and the ONE object built at
definition-compile time is what both listings — and every signal declared with
the type parameter's name — reference.

### The golden grid (Surelog v1.87, one arm per directory, every rc recorded)

`grid.sh` runs `surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`,
then both binaries, then the official `uhdm-cmp`.  Every arm below compiled
`slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.  Cells are read by `tpbounds.py`
/ `cen20.py` (keyed on the type parameter, the dim index and the side).

| arm | shape | golden cell |
|---|---|---|
| `t1` | module ANSI port list, both keywords | `PT` and `LT` both `op11[ref(W),UINT:1]` — the keyword is irrelevant |
| `t2` | the bound KINDS | `[7:0]` -> two constants (ours already agreed); `[W:0]` -> a BARE `ref(W)`; `[W-1:0]` -> `op11`; `[W+1:2]` -> `op24[ref(W),UINT:1]` with a LITERAL right bound; `[$clog2(W)-1:0]` -> `op11[sys_func_call($clog2)[ref(W)],UINT:1]` with the sys call spanning the WHOLE call (`9:34-9:43`), not the name; `[(W*2)-1:0]` -> `op11[op25[ref(W),UINT:2],UINT:1]`, the parens dropped; `[W-1:0][3:0]` -> dim 0 symbolic, dim 1 literal — PER DIM, PER BOUND |
| `t3` | override and re-pass | `u1` `.PT(logic [2:0])` -> literal constants; `u2` `.PT(logic [W-1:0])` -> **`INT:4`, FOLDED** — an override is compiled during ELABORATION and IS reduced (ours already agreed, both before and after); `u0` (not overridden, `LW` overridden to 5) -> its port var `work@dut.u0.p` points at the DEFINITION `work@leaf.PT` typespec, symbolic `op11[ref(LW),UINT:1]`; golden mints NO instance copy of a non-overridden type parameter at all |
| `t4` | package type params + the cross-package squares | `pk::PPT`/`pk::PLT` keep the bare `ref(PW)` AND bind it (`vpiActual` -> the package parameter's def constant at `5:23`); the MODULE side substitutes in all three written forms — `QT` `[pk::PW-1:0]` -> `op11[const(UINT:6,sz=32,ct=9),UINT:1]`, `CT` `[pk::PW:0]` -> the substituted constant ALONE (never a `ref_obj`), `BT` `[PW-1:0]` under a wildcard import -> the same substitution (§ crossPkgRangeBoundFold / § pkgBoundFoldBareImport) |
| `t5` | the corpus shape of `param_nested_struct_field_width`, trimmed | `sel_t` `op11[ref(NLOG),UINT:1]`, `sid_t` `op11[ref(SID_W),UINT:1]` |
| `t6` | INTERFACE, NON-ANSI header, module BODY params | `work@ifc.IT`, `work@nonansi.NT`, `work@nonansi.ML` all symbolic |
| `t7` | CLASS defn + gen-scope re-pass | `work@cls::CT` `op11[ref(CW),UINT:1]`; `work@leaf.GT` symbolic |
| `t8` | element classes | `bit [W-1:0]` -> `bit_typespec` symbolic; `logic signed [W-1:0]` symbolic; bare `int` has no range at all |
| `t9` | two declarators on one keyword, `$bits`, a typedef-named default | `PA`/`PB` both symbolic (`PB` `op11[ref(WA),UINT:2]`); `PC` `[$bits(PA)-1:0]` -> `op11[sys_func_call($bits)[ref(PA)],UINT:1]`; `PD = vec_t` takes the typedef's own (symbolic) typespec |

**The refs stay UNBOUND on the module/interface/class side** — no `vpiActual`
on `work@dut.PT.W`, `work@leaf.PT.LW`, `work@dut.sel_t.NLOG` or `t9`'s `$bits`
argument — and BOUND on the package side (`pk::PPT::PW` -> the package
parameter's def constant).  `VpiFullName` is scoped through the type parameter
(`work@dut.sel_t.NLOG`); `ref_obj::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp`) reads `VpiName`,
`VpiDefName`, `VpiGeneric`, `Actual_group` and `VpiStructMember` and never
`VpiFullName`, so only the binding half is judge-visible.

### Where it is implemented

Two producers had to move, because a type parameter's typespec is built twice
in our exporter where Surelog builds it once:

* `makeTypeParamDefaultTs` (`src/TypeEmit.cpp`) — the ANSI parameter-port-list
  arm, which minted a `UINT` constant spanning the WHOLE written bound;
* `makeTypespec`'s `emitBound` (`src/TypeEmit.cpp`) — everything else (body,
  package, class, interface, and every elaborated view), which minted an `INT`
  constant anchored at the binary expression's LEFT operand.

Both now route a non-literal bound through the new
`UhdmExporter::typeParamDefaultBound20`, gated on
`declSymbol.kind == SymbolKind::TypeParameter && !isOverridden()` so grid `t3`'s
`u2` override keeps the fold it already had right.

### What was NOT taken

A type-param default that NAMES a type and carries a packed dimension
(`localparam type rt_t = resp_id_t [DEPTH-1:0]`, corpus
`type_param_override_elem_sel` / `type_param_packed_dim`) goes through the
`packed_array_typespec` arm, not the logic-vector range arm; it is untouched
here and neither row moves.

---

## 3. § pkgBodyCallNeverListsOnHolder20 — the producer and its key

Our `importedTfCalls` registration (`src/ExprEmit.cpp`) fired on the BARE
SPELLING of a package-function call whenever `currentScope` was non-null.  A
package function called BARE inside its OWN package body is re-emitted while
`currentScope` is a MODULE — the borrowed package initializer the
assembled-struct family reduces for that module's elaborated `param_assign`
Rhs — and the spelling is bare there too, so the push hung the package function
on a module that neither imports it nor calls it.

The gate is the one Surelog's own resolver applies: **the bare name must
actually resolve to a package subroutine of that name FROM the listing scope**
(`importResolvesHere20`, `src/EmitHelpers.h`).  An IMPORT — the module's own, a
parent scope's, or the compilation unit's — makes it resolve; nothing else
does.  The resolved object need not be the SAME object (an importing package
contributes its own clone, § importedFreeCallTakesFirstListingImport227), so
the test is name + package-homed subroutine, not pointer identity.

### The golden grid — module `vpiTaskFunc` counts, golden / pristine / patched

| arm | shape | golden | pristine | patched |
|---|---|---|---|---|
| `b1` | the corpus shape: a package localparam initialised by a BARE call to the package's own function, read by the module as a struct-parameter default and used field-wise — NO import, NO call in the module | def 0 / elab **0** | def 0 / elab **1** | def 0 / elab **0** — CMP_EQUAL |
| `b2` | the module never mentions the package | 0 / 0 | 0 / 0 | 0 / 0 |
| `b3` | the same call written QUALIFIED inside the package | 0 / 0 | 0 / 0 | 0 / 0 |
| `b4` | **POSITIVE CONTROL** — the module WILDCARD-imports the package | 1 / 1 | 1 / 1 | 1 / 1 |
| `b5` | **POSITIVE CONTROL** — an EXPLICIT `import cfg_pkg::build_config;` | 1 / 1 | 1 / 1 | 1 / 1 |
| `b6` | the MODULE calls it, written QUALIFIED, no import | 0 / 0 | 0 / 0 | 0 / 0 |
| `b7` | the package localparam is a literal struct — no call anywhere | 0 / 0 | 0 / 0 | 0 / 0 |
| `b8` | the same read ONE INSTANCE DOWN, and a package function calling a second one | 0 on the elab child | **1** on the elab child | 0 |
| `b9` | the function-built package localparam is a plain `int`, not a struct | 0 / 0 | 0 / 0 | 0 / 0 |

`b4` and `b5` are the controls that matter: the import machinery this pass does
NOT touch keeps listing exactly one entry in both views, golden and ours.
`b8`'s own head is a different, unrelated object (9 lines, byte-identical
pristine and patched), so `b8` is a census witness, not a head arm.

---

## 4. The patched grid

| arm | pristine | patched |
|---|---|---|
| `t1` `t2` `t3` `t6` `t8` `b1` | 1 head | **0 heads, 0 cmp lines — CMP_EQUAL** |
| `t5` | 1 head (`operation` 11:41) | 1 head, the OBJECT CHANGED: the `localparam int SID_W = CFG.u.sidWidth` elab Rhs constant (R0) |
| `t9` | 1 head (`operation` 6:33) | 1 head, the OBJECT CHANGED: `work@dut.PD`, the typedef-named default's extra range-less clone — PRE-EXISTING and identical in both binaries' cells |
| `t4` `t7` `b8` | 1 head | 1 head, **byte-identical pristine and patched** (t4: the package Parameters vector, whose type params we never materialize into the importing module; t7: the class member var's typespec) |
| `b2`–`b7` `b9` | 0 heads | 0 heads |

Keyed directional census (`cen20.py`; TP = a type parameter's range-bound cell,
TF = an instance's `vpiTaskFunc` listing):

```
t1 TO=2  AWAY=0     t6 TO=3  AWAY=0     b1 TO=1  AWAY=0
t2 TO=6  AWAY=0     t7 TO=2  AWAY=0     b8 TO=1  AWAY=0
t3 TO=2  AWAY=0     t8 TO=3  AWAY=0     b2..b7,b9 TO=0 AWAY=0
t4 TO=5  AWAY=0     t9 TO=3  AWAY=0
t5 TO=3  AWAY=0
```

**AWAY-GOLDEN 0 on every arm.**  The cells the census prints as
`MOVED-STILL-WRONG` all read `g=<absent>`: they are the ELABORATED INSTANCE
COPIES of a non-overridden type parameter (`work@dut.u0.PT`,
`work@dut.i0.IT`, `work@dut.gb[0].u.GT`, …) — objects we already emitted before
this pass and golden emits nowhere (r11u18 R4).  Their bound now matches the
definition object golden actually carries; they are counted STILL-WRONG, never
AWAY, and `uhdm-cmp` confirms they are judge-invisible (`t3`, `t6` are
CMP_EQUAL with those copies present).

---

## 5. The mover set, PREDICTED BY NAME BEFORE THE PATCHED DATABASES WERE READ

`predL1_20.py` (L1, SOURCE-keyed — nothing in a database records that a bound
was WRITTEN symbolically) and `predL2_20.py` (L2, PRISTINE-DATABASE-keyed, with
a POSITIVE CONTROL).

* **u2r L1 predicted:** `arb_idx_cast`, `bits_of_type_param`, `cva6_equiv`,
  `cva6_struct_param_field`, `gen_scope_numports`, `ibex`,
  `packed_array_reset_loop`, `packed_array_struct`,
  `param_name_collision_typeparam`, `param_nested_struct_field_width`,
  `type_param_override_elem_sel`, `type_param_packed_dim`.
* **u2r L2 predicted:** `param_nested_struct_field_width`,
  `struct_param_field_shift`, `rp32_r5p_bru`, `rp32_r5p_mdu`.
* **L2 POSITIVE CONTROL:** the same detector run over grid arm `b1`'s PRISTINE
  database reports `b1 uhdmtopModules <- cfg_pkg::build_config`.  A census zero
  from this detector is therefore a reading, not a silence.

Measured (`byteverify.sh SELFCHECK=1`, `tools/probe/r10oth4repro/byteverify.sh`,
patched vs this pass's OWN pristine workdirs):

* **u2r: MOVERS 14 / 1608**, selfcheck 1607/1608 — 7 names x 2 modes:
  `arb_idx_cast`, `bits_of_type_param`, `gen_scope_numports`,
  `packed_array_reset_loop`, `param_name_collision_typeparam`,
  `param_nested_struct_field_width`, `struct_param_field_shift`.
  **Zero unpredicted movers.**
* **surelog: MOVERS 4 / 960**, selfcheck 959/960 — `MiniAmiq` x 2 modes,
  `Scoreboard`/default and `SeqDriver`/default: the PROVEN UVM COIN FAMILY and
  nothing else.  **No law mover on the surelog corpus at all.**

### surelog L1 / L2 predictions, and why nothing moved

* **L1 predicted** (`predL1_20.py` over `Surelog/tests` + `third_party/tests`,
  35 files): `Ariane2024`, `AzadiRTL`, `ClassScope`, `StructParamFieldRange`,
  `StructParamFuncBodyFieldCompare`, `StructParamPatternInitCast`, `Tnoc`,
  `TypeParam2`, `ariane`.  `Ariane2024` is SLANG_REJECT/NO_DATABASE and
  `AzadiRTL`, `ClassScope`, `Tnoc`, `TypeParam2` are SLANG_REJECT in both
  modes; `ariane` is not a row; and the three `StructParam*` rows' type-param
  defaults are ANONYMOUS STRUCTS (`type it_t = struct packed { logic
  [Cfg.XLEN-1:0] ... }`) whose member bound the regex matched — the
  `buildStructTs` arm, not the logic-vector range arm.
* **L2 predicted** (`predL2_20.py` over both pristine surelog mode workdirs):
  `ApbSlave`, `Earlgrey_0_1`, `EvalFuncNamed`, `FileList`, `FuncCase`,
  `FuncStruct`, `Rggen`, `Scoreboard`, `SeqDriver`, `SimpleUVM`, `UnionCast`.
  Every one of them carries a REAL import, which the C++ gate resolves through
  `Lookup::unqualified` (including the chained and compilation-unit forms the
  prediction's source scan cannot follow), so none moves.  Measured directly,
  the `vpiTaskFunc` listing size is IDENTICAL pristine and patched on every one
  that produces a database: `ApbSlave` 106, `FileList` 4, `Rggen` 1875,
  `SimpleUVM` 3634, `SeqDriver` 4528, `Scoreboard` 1946, `MiniAmiq` 3671 (both
  modes).  The law removes nothing here.

### Coin attribution, ORDER-BLIND + POSITIVE CONTROL

Sorted, path-normalised dumps of the four surelog movers:
`Scoreboard`/default **0** lines (a pure order flip); `MiniAmiq`/default,
`MiniAmiq`/testflags and `SeqDriver`/default **4** lines each, and each is one
`UINT:<n>` plus its `vpiDecompile` — the line-number class.

POSITIVE CONTROL: the PRISTINE binary re-run three times on `MiniAmiq`/default
gives three DIFFERENT databases (`7e06fb793a43`, `2ca4e20dfe7c`,
`8a9723329730`), none equal to its own sweep hash (`b3e13b97f696`).  Pinned by
NAME and by the coin CLASS, never by the count.

Why the predicted names that did NOT move did not move (the predictors are
deliberate SUPERSETS):

* `cva6_equiv` — not a discovered row (a flist directory with no `dut.sv`), and
  its only hit is the literal `logic [7:0]`;
* `cva6_struct_param_field`, `packed_array_struct` — the type-param default is
  an ANONYMOUS STRUCT (`= struct packed {...}`); the regex matched a MEMBER's
  bound, which goes through `buildStructTs`;
* `ibex` — `parameter type StateEnumT = logic [Width-1:0]` lives in
  `prim/prim_sparse_fsm_flop.sv` and `prim/prim_flop_macros.sv`, which are not
  discovered rows; the string `StateEnumT` appears in **0** of the 1608
  pristine databases;
* `type_param_override_elem_sel`, `type_param_packed_dim` — their non-literal
  defaults are TYPE-NAMED with a packed dimension (`resp_id_t [DEPTH-1:0]`), the
  `packed_array_typespec` arm; their `logic` defaults are literal;
* `rp32_r5p_bru`, `rp32_r5p_mdu` — their `riscv_isa_i_pkg` listing comes from a
  CHAINED import that L2's source-level import test cannot see but
  `Lookup::unqualified` resolves, so the gate keeps them.

**Directional census on every law mover** (`rowcen20.sh`, keyed, against each
row's OWN golden), BOTH MODES, identical in both:

| row | TO-GOLDEN | AWAY-GOLDEN | still-wrong (all `g=<absent>`) |
|---|---|---|---|
| `arb_idx_cast` | 1 | 0 | 0 |
| `bits_of_type_param` | 1 | 0 | 0 |
| `gen_scope_numports` | 2 | 0 | 12 |
| `packed_array_reset_loop` | 1 | 0 | 0 |
| `param_name_collision_typeparam` | 1 | 0 | 3 |
| `param_nested_struct_field_width` | 4 (3 bounds + the `pk::build`/`pk::mku` listing) | 0 | 0 |
| `struct_param_field_shift` | 1 (`cfg_pkg::build_config` listing dropped) | 0 | 0 |

**AWAY-GOLDEN 0 and MOVED-WRONG 0 on all 14 measured mover sides.**

A per-LINE multiset census (`rowline20.sh`) is MISLEADING for both laws and
says so in its own header: § typeParamDefaultBoundNoReduce20 turns ONE constant
into an operation tree, so generic lines (`|vpiParent:`, `|vpiOperand:`,
`|vpiConstType:9`, `|UINT:1`) multiply on every object we carry that golden does
not, and the folded constants the law removes are counted against unrelated
`UINT:<n>` lines elsewhere in the design.  Every AWAY key it reports is either
such a generic line or a `ref_obj` on an elaborated instance copy golden emits
nowhere (`g=0`).  The KEYED census above is the measurement.

---

## 6. Head movement on the two targets

| test | pristine head | patched head |
|---|---|---|
| `struct_param_field_shift` | `LHS: <null>` / elab `module_inst`, our extra `Task_funcs` entry | **CLEARED — 0 heads, 0 cmp lines, CMP_EQUAL in BOTH modes.  THE TEST CONVERTS.** |
| `param_nested_struct_field_width` | `operation` 41:44, the `NLOG-1` bound | **CLEARED** -> `constant` at `36:37`: `localparam int SID_W = CFG.u.sidWidth`'s elaborated Rhs.  Golden has `BIN:…0011` sz 32 ct 3 with a BARE `ref_typespec` -> the struct MEMBER's own `int_typespec` (`7:5-7:17`) and the span of the BASE NAME `CFG` alone; we have `UINT:3` ct 9 with a `work@dut`-named ref -> the LOCALPARAM's own `int_typespec` and the span of the whole `CFG.u.sidWidth` read (R0) |

The five collateral movers all moved TO golden on their own bound cells; none
of them converts, and each keeps or advances its own head.  Rising cmp line
counts on those rows are the NEW head's size, not a partial fix.

Scoreboard, both corpora, both modes:

| corpus | mode | pristine | patched |
|---|---|---|---|
| uhdm2rtlil | default | 763 / 41 / 67 | **764 / 40** / 67 |
| uhdm2rtlil | testflags | 763 / 41 / 67 | **764 / 40** / 67 |
| Surelog suite | default | 468 / 15 | 468 / 15 |
| Surelog suite | testflags | 464 / 13 | 464 / 13 |

---

## 7. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `aa69cb57` | `0691f7273455a3628c2de8fcc773ef90` — BYTE-IDENTICAL (the value the brief pins) |
| patched build md5 | `e234b1297f348201f0cf9350691decc9`, and the committed source REBUILDS to it byte-for-byte |
| `tests/check_goldens.sh` (patched) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | ONE row differs and it is the CONVERSION, quoted in full at the top |
| u2r both modes vs `results/golden_uhdm2rtlil.csv` | TWO rows differ, the same conversion in each mode, quoted |
| u2r patched vs this pass's own pristine sweep, both modes | the same single row, both modes |
| u2r scoreboard | 763 / 41 / 67 pristine -> **764 / 40 / 67** patched, both modes |
| surelog patched | 468/15 default + 464/13 testflags — identical to this pass's pristine sweep AND to the committed baseline |
| surelog vs `results/golden_surelog.csv` and vs own pristine | 2 rows differ, BOTH only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string (`LowMemLib`, `LowMemPkg`); 0 status moves, 0 dump-column moves |
| `byteverify SELFCHECK=1` u2r | 14 / 1608, selfcheck 1607/1608, every name predicted a priori, every moved cell TO-GOLDEN |
| `byteverify SELFCHECK=1` surelog | 4 / 960, selfcheck 959/960 — the proven coin family alone, attributed order-blind with a positive control |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS (ok=58 changed=0) / PASS (ok=1 changed=0) |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` `4842211c4030`, `YosysVerx` `6ccda350c24a` — both modes, both binaries |
| STATUS pins | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` (`e3e354129d5a` default / `73a10e8217e5` testflags), `YosysOldOr` `d68e0796d62c` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched (12 measured, 2 SKIP-NOFILE as expected) |
| every `cmds.txt` audited BY BINARY PATH | 1742 + 1531 pristine rows name the frozen pristine binary, 1742 + 1531 patched rows name the frozen patched one, nothing else |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits in `tools/probe/r11u20repro/`; no driver dispatches them |
| `results/*.csv` | UNTOUCHED |
| patch applies clean on a FRESH `aa69cb57` worktree | yes, 0 conflicts, 0 `<<<<<<<` markers |

---

## 8. Residues

* **R0 — a struct-FIELD-read localparam's elaborated constant.**  `localparam
  int SID_W = CFG.u.sidWidth` (and `t5`'s twin): golden's elab Rhs takes the
  struct MEMBER's encoding, size and `vpiConstType` (`BIN:…0011`, sz 32, ct 3),
  a BARE `ref_typespec` whose Actual is the MEMBER's own `int_typespec`, and the
  span of the BASE NAME alone; we emit `UINT:3` ct 9 at the whole-read span with
  a ref named after the declaring module and pointing at the LOCALPARAM's
  `int_typespec`.  This is the NEW head of `param_nested_struct_field_width`
  and of grid arm `t5`, and it is the § assembled-struct family's next cell.
* **R1 — the DUPLICATE type-parameter typespec.**  Surelog builds ONE object at
  definition-compile time and every view and every type-param-typed signal
  references it; we mint one per view (grid `t1`: golden 1 full print of the
  `logic_typespec` at `6:26`, ours 2 — one parented at the `type_parameter`,
  one at the elaborated `logic_var`).  Judge-invisible today because both now
  carry the same cells, but it is an object golden does not have.
* **R2 — the ELAB instance copies of a non-overridden type parameter.**
  `work@dut.u0.PT`, `work@dut.i0.IT`, `work@dut.gb[0].u.GT`: golden
  re-references the DEFINITION object, we mint an instance copy.  Unchanged by
  this pass (r11u18 R4), judge-invisible (`t3`/`t6` are CMP_EQUAL with them
  present).
* **R3 — a wildcard-imported package's TYPE parameters are not materialized.**
  Grid `t4`: golden's importing module lists `work@dut.PPT` and `work@dut.PLT`
  (the package's type params, copied in exactly as the value params are); we
  list neither.  This is `t4`'s head and it is untouched here.
* **R4 — the type-param bound ref's `VpiFullName` spelling.**  Golden writes
  `pk::PPT::PW` and `work@cls::c::CW`; we write `pk::PPT.PW` and
  `work@cls::CT::CW`.  `ref_obj::Compare` never reads `VpiFullName`, so this is
  a dump residue only.
* **R5 — `struct_member_cfg_width`** still wants a `ref_typespec` on a
  `logic_net` typed by a MODULE-LOCAL typedef with parameter-driven member
  widths (r11u18 R3).  Not touched.

**R0 for the next pass: a localparam whose initializer READS A FIELD of a
struct parameter takes the MEMBER's encoding, size, `vpiConstType` and
typespec, and the span of the BASE NAME — not the declaring parameter's.  Grid
arm `t5` and the corpus row `param_nested_struct_field_width` are the
ready-made witnesses and both golden cells are tabulated in §6.**

---

## 9. Files

| file | what it is |
|---|---|
| `grid.sh` | the golden grid runner: Surelog v1.87 + both binaries + official `uhdm-cmp` per arm, every rc recorded |
| `t1`–`t9` | the § typeParamDefaultBoundNoReduce20 arms (§2) |
| `b1`–`b9` | the § pkgBodyCallNeverListsOnHolder20 arms (§3); `b4`/`b5` are the POSITIVE CONTROLS |
| `tpbounds.py` | lists every `type_parameter`'s typespec range-bound SHAPE, side by side |
| `cen20.py` | the KEYED directional census for both laws (TP bound cells + TF listings) |
| `rowcen20.sh` | `cen20.py` on named SWEEP rows against each row's own golden |
| `dirline20.sh`, `rowline20.sh` | the per-LINE directional census, with its blindness documented in its own header |
| `predL1_20.py`, `predL2_20.py` | the a-priori mover predictions (source-keyed L1, pristine-database-keyed L2 with a positive control) |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery that RUNS here |
