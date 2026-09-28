# r11u202: the module/type ground, pair B (refill after pass 196): the r11u200 ground-B laws landed and reconciled with pass 196, $unit class-specialization typedefs and module-variable specializations (ClassTypeParam converts), class value parameters written `int`, module-scope package-generic specializations, generate-scope variable initializers

Base `ddc67d87` (branch matrix-1.87, the r11u200 decode). Files of the ground touched: `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp`, `src/UhdmExporter.cpp` (`uhdm_main.cpp` needed nothing). No line of the
sister's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of `include/`,
`scripts/`, `results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated
(`python3 scripts/law_index.py`, run last).

**Verdicts per targeted row** (fresh csv rows of the law sweep `/tmp/r11u202_sL`; `results/` untouched):

| row-mode | base (`results/`) | after | laws |
|---|---|---|---|
| **ClassTypeParam d/t (surelog)** | `STRICT_NOTEQUAL differ:endline(17)` / `differ:file(30)` | **`ClassTypeParam,default,CMP_EQUAL,,,equal`**, **`ClassTypeParam,testflags,CMP_EQUAL,,,equal`** | § unitClassTdSpecAtName202, § unitClassTdEndAtInit202, § classSpecExprArgUnlocated202 |
| **int_types d/t (uhdm2rtlil)** | `STRICT_NOTEQUAL differ:fullname(82)` | **`int_types,default,CMP_EQUAL,,,equal`**, **`int_types,testflags,CMP_EQUAL,,,equal`** | § tfSigningSpanFollowsCompilePath200, § defGenInitRhsKeepsParent200 (the r11u200 laws, landed here) |
| SVSwitch d/t | `differ:fullname(13)` | `differ:fullname(2)` | § ifaceArrPortElemViewNamedByArray200, § implicitTsEndCrossesLineBreak200; the last two records are pair A's new[] law (r11u200's newArrayArgPathElemsStripped200, ExprEmit): with it both modes convert (r11u200 measured the composition) |
| Scr1SvTests d/t | `differ:endcol(29)` | `differ:endcol(11)` | § defPortPackedTsKeepsWholeSpan200, § unitBoundFoldAtLeftOperand200 (the $unit initializer half); `type(1)` needs pair A's bound half (r11u200 section 3d) |
| UnitElabBlock d/t | `differ:endline(13)` / `endline(12)` | `differ:file(2)` / `file(1)` | § implicitTsEndCrossesLineBreak200; the last record is ExprEmit's (section 7, S1) |
| Earlgrey_0_1 d/t | `differ:fullname(82)` | `differ:endcol(80)` | § defPortPackedTsKeepsWholeSpan200 |
| Rggen d | `differ:endcol(144)` | `differ:defname(142)` | § defPortPackedTsKeepsWholeSpan200 |
| MiniAmiq d/t | `differ:file(17)` | `differ:file(91)` | the walk runs past `get_event_pool` (§ classTdRetSharesTypedefTs200) |
| SeqDriver d/t | `differ:fullname(16)` | `differ:fullname(85)` | the same |
| SimpleUVM d/t, Scoreboard d | `differ:fullname(44)` | `differ:fullname(115)`, `differ:fullname(123)` | the same |
| BuildUVMPkg d/t | `differ:line(11)` | `differ:line(24)` | the same |

The UVM counts grow because the comparator reaches more records before the walk diverges (the first record of each
row is unchanged, section 5); the order-blind distance to golden falls on every one of them (section 6).

Gate totals: probe **`regressions=0 conversions=14 changes=13`** (EQUAL 3345 -> 3359); surelog **`regressions=0
conversions=2 changes=18`**; uhdm2rtlil **`regressions=0 conversions=2 changes=0`**; downstream **803 IDENTICAL / 66
SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**, `downstream.csv` byte-identical to the pristine sweep's. 22 of 2560 corpus
databases move, **22 of 22 predicted by name** from the frozen firing census; uhdm-cmp reads 0 lines on every one.

**The fence.** The four slang-fenced names come from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`;
every driver here resolves its paths from the repo that holds it and reads them fail-closed (`drivers/env.sh`, and
`case.sh`, `grid.sh`, `bytectl.sh`, `switches.sh`, `rowrun.sh`, `det.sh`, `bvmirror.sh`, `uvmdist.sh`, `dscase.py`,
`census.sh` which runs the corpora with `--filter` built from the fence). The byte comparisons ran on hard-link
mirrors that leave the 8 fenced row-mode databases out (`fenced_skipped=8`). No fenced test was run, read or decoded
outside the gate sweeps, which dispatch every row themselves; their csv verdicts are the only fenced facts cited (none
moved). No gdb was used.

## 0. Switches

Every r11u202 law reads its own `R11U202_<LAW>_OFF` through `r11u202Law` (`UhdmExporter.cpp`, beside `r11u200Law`);
**`R11U202_OFF=1` drops all of them and the r11u200 laws landed here** (`r11u200Law` reads it too). The r11u200 laws
keep their own `R11U200_<LAW>_OFF` switches and `R11U200_OFF`. `R11U202_TRACE=<dir>` and `R11U200_TRACE=<dir>` name
every firing (one file per process, `<pid>.202` / `<pid>.200`, first line `OUT <-o path>`, then `<law> <detail>`).

| switch | law | file |
|---|---|---|
| `R11U200_SIGNSPAN_OFF` | § tfSigningSpanFollowsCompilePath200 | TypeEmit.cpp, TaskFuncEmit.cpp, ModuleEmit.cpp |
| `R11U200_GENINIT_OFF` | § defGenInitRhsKeepsParent200 | ModuleEmit.cpp |
| `R11U200_IFARRNAME_OFF` | § ifaceArrPortElemViewNamedByArray200 | ModuleEmit.cpp |
| `R11U200_IMPLEND_OFF` | § implicitTsEndCrossesLineBreak200 | TypeEmit.cpp |
| `R11U200_PORTPACKED_OFF` | § defPortPackedTsKeepsWholeSpan200 | ModuleEmit.cpp |
| `R11U200_UNITINIT_OFF` | § unitBoundFoldAtLeftOperand200, the $unit initializer half | UhdmExporter.cpp |
| `R11U200_CLASSCRASH_OFF` | § modGenericClassListedAtDefault200 (reconciled: the fallback form, section 1) | ModuleEmit.cpp, TypeEmit.cpp |
| `R11U200_CLASSTDRET_OFF` | § classTdRetSharesTypedefTs200 | TaskFuncEmit.cpp |
| `R11U200_POSREFMOD_OFF` | § posOpConnKeepsRefModule200 | ModuleEmit.cpp |
| `R11U200_GENBITS_OFF` | § genBlockBitsKeepsSelect200, the definition-listing half | TypeEmit.cpp |
| `R11U202_UNITCLSTD_OFF` | § unitClassTdSpecAtName202 | UhdmExporter.cpp |
| `R11U202_CLSTDINITEND_OFF` | § unitClassTdEndAtInit202 | UhdmExporter.cpp |
| `R11U202_SPECARGS_OFF` | § classSpecExprArgUnlocated202 | UhdmExporter.cpp (`respanSpecArgs202`), TypeEmit.cpp (the module-variable site) |
| `R11U202_CLSPARAMSIGN_OFF` | § classValueParamIntSigned202 | UhdmExporter.cpp (`emitClassParameters`) |
| `R11U202_MODPKGSPEC_OFF` | § modPkgGenericSpecNamedBare202 | TypeEmit.cpp |
| `R11U202_VALSPECSPAN_OFF` | § modSpecValueArgSpanAtName202 | TypeEmit.cpp |
| `R11U202_GENINITBIND_OFF` | § genVarInitOuterRefUnbound202 | ModuleEmit.cpp (the elaborated generate-variable initializer) |
| `R11U202_GENINITBS_OFF` | § defGenInitBitSelAtIndex202 | TypeEmit.cpp (`emitSyntaxExpr`), ModuleEmit.cpp (armed at § defGenInitRhsKeepsParent200's site) |
| `R11U202_OFF` | all of the above | |

**OFF check.** `R11U202_OFF=1` on the law binary writes the pristine bytes on **all 4087 `tests/probe` databases**
(`check_probe.py` rerun under the switch, every database compared with the pristine sweep's: 0 differ; its `probe.csv`
equals `results/golden_probe.csv`) and on **84 of 84** cases of this directory and **88 of 88** of
`tools/probe/r11u200dec/cases` ([evidence/grids/](evidence/grids/), last column). **Each switch alone**
([evidence/switches/switches_alone.txt](evidence/switches/switches_alone.txt), `drivers/switches.sh` over both case
sets): every switch moves only cases whose plain run traced its own law (`UNTRACED 0`); `R11U200_CLASSCRASH_OFF`
moves nothing, as designed (its form runs only under pass 196's switches, section 1).

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u202_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `18183f058868a85659208c85a099980e` | worktree `/tmp/wt_r11u202` at `ddc67d87`, system deps, `-j 2`: = the main tree's `build/slang-uhdm` |
| `l200.bin` | `1399c846958d5ce0274649a5529281bb` | `ddc67d87` + `tools/probe/r11u200dec/law_typeemit.patch` rebased over pass 196 (the reconciled class listing, section 2) |
| `d6.bin` (**the law binary**) | `8214d7927295a3b3eefe3ee87df53cbd` | the delivered sources (`d1`, `d3`, `d4`, `d5` are development builds; section 3 names what moved between them) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

The delivered patch applied to a FRESH worktree of `ddc67d87` (`git apply`, clean) builds (system deps, `-j 2`) to
`8214d7927295a3b3eefe3ee87df53cbd`, the law binary's md5.

## 2. (0) The r11u200 ground-B laws: rebase, reconcile, alone, composed

**Rebase.** `law_typeemit.patch` (drafted at `a015c911`) did not apply on `ddc67d87`: pass 196 touched the same four
files. A three-way merge (`git merge-file`, base `a015c911`) applied every hunk but two, both on one face: r11u194's N1,
the parameterized class declared in a module body, which pass 196 landed first as § modGenericClassListed196 (the
listing), § modGenericHandleBare196 (the bare handle typespec) and § modClassTsLinksDefListing196.

**Reconciliation: one rule, one switch family.** Pass 196's form is a strict superset of the r11u200 draft (the draft
listed the body's generics only, and bared the handle only when the generic's parent scope IS the instance body;
pass 196 also walks generate blocks, program homes and the listing sites). Pass 196's code is THE rule; the r11u200
form is kept as its fallback, alive only when `R11U196_MODGENERIC_OFF` / `R11U196_MODGENHANDLE_OFF` drop pass 196's
halves (`R11U200_CLASSCRASH_OFF` drops the fallback), so each form is measurable alone
([evidence/grids/compose_classlisting.tsv](evidence/grids/compose_classlisting.tsv), `drivers/compose.sh`, four
configurations on r11u200dec K, r11u196repro MG and this directory's K):

| configuration | EQUAL of 24 | `--elabuhdm` |
|---|---|---|
| neither (pristine binary, the three 196 switches off) | 2 | rc 139 on K/k01 (the r11u194 crash, positive control) |
| pass 196 alone (pristine binary) | 15 | rc 0 everywhere |
| r11u200 alone (`l200.bin`, the three 196 switches off) | 11 (m09, m11, m13, ma05 not reached) | rc 0 everywhere |
| both (`l200.bin`) | 15, **byte-identical to pass 196 alone on all 24** | rc 0 everywhere |

The listing ORDER question (the draft pushed generics in member order, pass 196 after the plain classes) is moot:
golden's dump lists a module's classes in its own order (`box`, `zeta`, `alpha` for source order `zeta box alpha`,
cases K/k01, K/k02) and both forms read STRICT_EQUAL.

**Alone.** The full gate sweep of `l200.bin` (`/tmp/r11u202_sA`, [evidence/sweeps/sweep_A.txt](evidence/sweeps/sweep_A.txt)):
probe `regressions=0 conversions=12 changes=13`, surelog `regressions=0 conversions=0 changes=18`, uhdm2rtlil
`regressions=0 conversions=2 (int_types d/t) changes=0`, downstream 803 / 66 / 2 / 0 with `downstream.csv`
byte-identical to the pristine sweep's: exactly r11u200's lawB-alone column (its section 9: 12 / 13 probe, 18 surelog
changes, int_types d/t), now on top of pass 196. On r11u200's own grid ([evidence/grids/grid_r11u200dec_pris_l200.tsv](evidence/grids/grid_r11u200dec_pris_l200.tsv))
`l200.bin` agrees with r11u200's lawB column on 85 of 88 cases; the other three (K/k01 k03 k07) are EQUAL in both
because pass 196 had already converted them at the base.

**Composed with pass 196** (the law binary's sweep, section 4): pass 196's rows and cases keep their verdicts; its
cases are byte controls (section 4, `bytectl`): every r11u196repro / v11u196repro case that moves moves by a firing
of a law of this pass, and none leaves EQUAL.

**Re-verified with fresh cases of my own** ([cases/R0](cases/R0), 2-5 per law, judged pristine -> r11u200 alone -> law):

| law | cases | pristine -> law |
|---|---|---|
| § tfSigningSpanFollowsCompilePath200 | s01 (a package class method's `shortint unsigned` return and ANSI formals; a task; a non-ANSI `reg signed` formal), s02 (generate-block variables, a `bit signed` function), s03 (types from a macro argument, a return and formal split across lines) | 3 x endcol -> **EQUAL** |
| § defGenInitRhsKeepsParent200 | v01 (operation and concatenation initializers, a nested named block), v02 (a gen-case branch, a gen-for) | NOT_EQUAL -> v01 **EQUAL** (with § genVarInitOuterRefUnbound202), v02 `fullname(2)` (an unnamed case-branch block's variable named `.a`, residue R8) |
| § ifaceArrPortElemViewNamedByArray200 | i01 (a program, `[3]`, a scalar port beside the array), i02 (`[1:0]`, a program and a module on one array) | 2 x fullname -> **EQUAL** |
| § implicitTsEndCrossesLineBreak200 | l01 (a tab, a comment before the line break), l02 (an ANSI header) | 2 x endline -> **EQUAL** |
| § defPortPackedTsKeepsWholeSpan200 | m01 (non-ANSI `wire`/`logic` three-dimensional ports, control: equal already), m02 (a parameterized child) | m02 endcol -> **EQUAL**, m01 EQUAL both |
| § classTdRetSharesTypedefTs200 | t01 (an extern method returning a typedef of a value-parameter specialization), t02 (a static method, a local of the typedef type) | t02 name -> **EQUAL**; t01 NOT_EQUAL -> **EQUAL** (with § classValueParamIntSigned202) |
| § posOpConnKeepsRefModule200 | q01 (operation / unary first, operation later), q02 (a conditional first beside `sub #() u2(...)`), q03, q04 (q02's two instances alone), q05 (q02 without `#()`) | q01 q03 q04 q05 NOT_EQUAL -> **EQUAL**; q02 NOT_EQUAL both: the pre-existing textual-override rule (`textMultiParamDefs`) reads `#()` and no override as two texts and drops both ref_modules (residue R9) |
| § unitBoundFoldAtLeftOperand200 ($unit initializer) | u01 (`(M << 3) \| 4 \| 1`, `M * 2 + 3 - 1`) | NOT_EQUAL both: its first object is the folded constant's value and type, the ground-A half (ParamEmit) |
| § genBlockBitsKeepsSelect200 (definition listing) | b01 (a gen-for `$bits(x[4:0])`) | NOT_EQUAL both: the elaborated half is ExprEmit's (pair A) |
| § modGenericClassListedAtDefault200 (reconciled) | K/k01, K/k02 (listing order), K/k03 (a program home, value argument) | EQUAL at the base (pass 196); k03 NOT_EQUAL -> **EQUAL** (with § classValueParamIntSigned202 and § modSpecValueArgSpanAtName202) |

No fresh case breaks where pristine was right.

**Downstream of the r11u200 laws** (the gate's own `one()`, [evidence/downstream/cases.txt](evidence/downstream/cases.txt)):
r11u194 Z/z01 and r11u200dec K/k01, k08 read IDENTICAL, K/k02 EQUIVALENT in both the pristine and the law binary (pass
196 had already fixed the crash). The `$bits` cases (r11u199 W/w8, r11u200dec B/b01 b03 b04 b05) stay **DIVERGENT**:
the elaborated fold is the ground-A half of § genBlockBitsKeepsSelect200 (ExprEmit), which pair A carries; with it
r11u200 measured all five IDENTICAL. c06 and x06 stay DIVERGENT (r11u200's N6, N5: section 7).

## 3. The new laws (decode, grid, law)

**The grid of this directory** ([evidence/grids/grid_own_pris_l200_law.tsv](evidence/grids/grid_own_pris_l200_law.tsv),
`drivers/grid.sh`: each case judged as `scripts/check_probe.py` judges it, goldens from the pinned Surelog cached per
case text; columns pristine, r11u200 alone, law, and the law binary under `R11U202_OFF=1` against pristine bytes):

| family | cases | EQUAL pristine | EQUAL r11u200 alone | EQUAL law | converted by the law binary |
|---|---|---|---|---|---|
| CT (§ 3.1) | 27 | 2 | 2 | 22 | c01-c09, c12, c13, c18-c20, c22-c27 |
| CP (§ 3.2) | 4 | 0 | 0 | 3 | p01 p02 p03 |
| N2 (§ 3.3) | 7 | 0 | 0 | 7 | n01-n07 |
| UV (§ 3.4) | 8 | 0 | 0 | 5 | u01 u02 u04 u05 u07 |
| GI (§ 3.5) | 6 | 0 | 0 | 5 | g01-g04 g06 |
| K (the reconciled listing) | 3 | 2 | 2 | 3 | k03 |
| R0 (r11u200 re-verification, section 2) | 20 | 1 | 14 | 16 | i01 i02 l01 l02 m02 q01 q03 q04 q05 s01 s02 s03 t01 t02 v01 |
| TD, IM (decodes only) | 9 | 2 | 2 | 2 | - |
| **all** | **84** | **7** | **20** | **63** | **56**, 0 regressed, `R11U202_OFF=1` = pristine on 84 of 84 |

On r11u200's own grid ([evidence/grids/grid_r11u200dec_pris_l200_law.tsv](evidence/grids/grid_r11u200dec_pris_l200_law.tsv),
88 cases): EQUAL pristine 20, r11u200 alone 58, law **60** (K/k04 and K/k06 converted by § modPkgGenericSpecNamedBare202 and
§ classValueParamIntSigned202 + § modSpecValueArgSpanAtName202), 0 regressed, `R11U202_OFF=1` = pristine on 88 of 88.

### 3.1 ClassTypeParam: the $unit typedef of a class specialization and the module variable specialization

Head at the base (`build/uhdm-strictcmp`, default): `#121 endline class_typespec m_uvm_config_obj_misc` golden
`20:9-24:36`, ours `20:9-20:43`; `#122 file type_parameter T` golden unlocated, ours `16:27-16:28`; `#124 col
class_typespec uvm_object` golden `20:22-20:43`, ours `20:24-20:34`; `#141 line class_typespec uvm_object` golden
`26:16-26:37` (misc2's own `#(...)`), ours line 20's; `#144 string_typespec` golden `26:30-26:36`, ours line 20's.
Grid [cases/CT](cases/CT) (27 cases; goldens from the pinned Surelog):

* **§ unitClassTdSpecAtName202.** A `$unit` typedef of a class SPECIALIZATION is located at the class NAME alone
  (golden `typedef cfg#(int, string) m_misc;` 4:9-4:12, c07 c12; ClassTypeParam 20:9-20:22). Ours spanned through
  the `#(...)`. A package typedef (c14) and a class-scope typedef (c15) already agreed. Site: UhdmExporter's $unit
  typedef listing (the class alias branch).
* **§ unitClassTdEndAtInit202.** A MODULE-body variable typed by a `$unit` class typedef and declared with an
  initializer moves the END of the typedef's one class_typespec to the initializer's end (Surelog's compileVariable
  populates the variable's typespec end at the initializer, the rule § classVarInitSpan152 reads on a written
  specialization; here the typespec is the typedef's shared object: ClassTypeParam `m_uvm_config_obj_misc misc1 =
  new;` makes it 20:9-24:36). Every declarator writes and the LAST writer wins: modules in the order of their
  `work@<name>` keys, declarators in source order (c18: two in one module, the second wins; c24, c26, c27: across
  modules the alphabetically last module wins whatever the source order or the hierarchy). A class property (c20), a
  procedural block's variable (c22) and an assignment (c19) never move it; a plain class typedef moves the same way
  (c23).
* **§ classSpecExprArgUnlocated202.** The specialization's listing follows Surelog's compileDatastructureTypespec branches
  (transcribed in § classPropSpecForeignPkgHome163's builder): an argument written as a bare IDENTIFIER (a class name)
  parses as an expression, so its type_parameter and param_assign carry NO location and the actual class_typespec
  is located at the whole `#(...)`; a data-type argument keeps the formal's span on the type_parameter and the
  argument's own span on the actual. emitClassTsParams read slang's specialization, whose argument syntax is the FIRST
  spelling of that specialization anywhere, so a module variable `uvm_config_db#(uvm_object, string) misc2` (c04, c05,
  c25) re-read the typedef's line 20. The helper `respanSpecArgs202` re-applies both branches from the site's own `#(...)`:
  the $unit typedef (c01 c06 c08) and a module variable written as a specialization. Only an actual the listing owns
  is relocated.

Grid: pristine 2 of 27 EQUAL, law **22**; left: c10 (a package typedef used at module scope: Surelog writes an
`unsupported_typespec`), c11 (a module-scope typedef, structural), c16 (golden aliases two typedefs of one
specialization), c17 (`cfg#(nib_t, obj, bit [2:0])`: golden lists only the WRITTEN formals, ours every one:
emitClassTsParams' known shape, residue R5), c21 (a `= null` class variable initializer, residue R6).
**ClassTypeParam d/t CONVERT** (section 4); ClassParamAsParam (a canary) stays CMP_EQUAL.

### 3.2 § classValueParamIntSigned202: a class value parameter written `int` (r11u196's R2, first face)

Head (cases/CP/p01, `class c #(parameter int W = 4)` in a package): golden `int_typespec 3:23-3:26 |vpiSigned:1`
parented at the parameter, ours unsigned and unparented (stage 1). Grid [cases/CP](cases/CP) and K/k03: the typespec
is vpiSigned unless written `int unsigned` and is parented at the parameter in every form; the PARAMETER itself
carries vpiSigned only when a `parameter` / `localparam` keyword is written (p01, p02 body `parameter int W` signed;
`class c #(int W = 4)` p03, p04 not). Site: UhdmExporter `emitClassParameters` (§ classParamWrittenTypeTypespec54's
written-type branch). p01 p02 p03 converted; p04 keeps the second face of R2 (an unpacked `[W]` dimension constant
64-bit in golden, 32-bit in ours, typed by a copy of the parameter's typespec: residue R3). In the UVM rows the law
fires on `uvm_bit_rsrc` / `uvm_byte_rsrc`'s `int unsigned N`: the typespec gains its parent (golden's shape, the dump
line `|vpiParent: parameter (uvm_pkg::uvm_bit_rsrc::N)` in the weakly-referenced listing), nothing else moves.

### 3.3 § modPkgGenericSpecNamedBare202 (r11u194's N2, r11u200's K/k04: brief item (2) "write it")

A MODULE-body declaration written as a SCOPED specialization of a package generic (`p::c #(8) h;`, `p::b #(byte) h;`)
reaches Surelog's paPackage_scope branch, which compiles the class reference from the qualified NAME alone: golden
`class_typespec p::c` spanning `p::`, no vpiParameter / vpiParamAssign; ours named it `p::c #(8)` (judge-visible)
and listed the specialization. With an initializer the end runs to the initializer's end (golden 12:3-12:23 on
`p::b #(byte) h = new;`). Grid [cases/N2](cases/N2): n01-n07 (value, type and class arguments, with and without
`= new`, two declarators; n06 the unparameterized spelling) all **NOT_EQUAL -> EQUAL** (n06 through § 3.2);
r11u200dec K/k04 converts; r11u191dec Q/q01 moves from NOT_EQUAL to `type(1)`.

### 3.4 § modSpecValueArgSpanAtName202

A MODULE / PROGRAM variable written as an unscoped specialization whose every written argument binds a VALUE formal
(`c #(8) h;`) is located at the class NAME alone, in both views (golden 13:3-13:4, cases/UV u01; a module-local
generic alike, r11u196repro MG/ma03 `box #(8) b;` 6:3-6:6, K/k03 in a program). A type argument keeps the whole text
(u02, u05) and, for a module-local generic, pass 196's shape (MG/m09: the definition view spans `box #(byte)` 6:3-6:14,
the elaborated view the name): the first draft keyed on an empty listing and moved m09's definition-view span away
from golden (the strict comparator excuses it, golden giving that typespec two spans; found by the byte controls, not
by the gate), so the test is on the written arguments. With an initializer § classVarInitSpan152 governs (u04 equal).

### 3.5 § genVarInitOuterRefUnbound202 and § defGenInitBitSelAtIndex202 (r11u200's generate-initializer neighbours)

* Surelog binds the references of an ELABORATED generate-scope variable's initializer only among that generate
  scope's OWN variables and nets: a module variable, net or port, or a variable of an ENCLOSING generate scope, stays
  an unbound ref_obj (golden `work@g02.g1.a.q`, `work@g03.gf[0].gi.z.y`: no vpiActual), while `logic [7:0] a = x;`
  beside `x` in the same block binds (g01). Only a net or variable actual is dropped. Site: ModuleEmit's
  pendingGenVarInit drain.
* A definition-view generate-block variable's initializer is an rvalue: its bit_select is anchored at the INDEX
  (parentheses kept), as the elaborated copy already was (golden `logic c = q[0];` 7:17-7:18; ours 7:15-7:19 in the
  definition listing). Site: TypeEmit `emitSyntaxExpr`'s bit-select branch, armed by ModuleEmit around the initializer.

Grid [cases/GI](cases/GI): g01 g02 g03 g06 NOT_EQUAL -> **EQUAL**, g04 `fullname(5)` -> **EQUAL**; g05 keeps a
generate localparam's fold (`h = L`: golden `UINT:2` size 8, the existing constant-propagation branch; residue R7).
**Downstream** (the gate's `one()`): g06, where the generate variables drive outputs through `g1.a` / `g1.b`, reads
IDENTICAL (4 gates) in both binaries; g01-g05, v01, v02 IDENTICAL in both.

## 4. The gates (the law sweep `/tmp/r11u202_sL` against the committed baselines, beside the pristine `/tmp/r11u202_sP`)

Both sweeps are `tests/sweep.sh --jobs 3 --workdir <dir>` with `SLANG_UHDM` exported (`drivers/sweep.sh`); workdir
names of equal length; every `cmds.txt` `slang:` line names the sweep's own binary (3273 of 3273 in each;
[evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)). Each sweep exits 1 for one reason only, `law index
STALE`: the worktree's sources carry the new § names before `tests/LAWS.md` is regenerated (the main tree at the base
reads `--check` rc 0). Summaries: [evidence/sweeps/](evidence/sweeps/).

| gate | pristine `pris.bin` | law `d6.bin` |
|---|---|---|
| (1) build | = the main tree's `build/slang-uhdm` | `ddc67d87` + this patch |
| (2) probe vs golden_probe.csv | EQUAL 3345 / 742, `probe.csv` byte-identical to the baseline, `0 / 0 / 0` | **EQUAL 3359 / 728: `regressions=0 conversions=14 changes=13`** |
| (3) surelog vs golden_surelog.csv | `0 / 0 / 0` | **`regressions=0 conversions=2 changes=18`**; judge-equal 461+19 default, 457+17 testflags unchanged in sum (CMP_NOTEQUAL 3 / 3 unchanged) |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `0 / 0 / 0` | **`regressions=0 conversions=2 changes=0`** |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **the same; `downstream.csv` byte-identical to the pristine sweep's** |
| (5) uhdm-cmp | | **0 lines on all 22 movers** ([evidence/sweeps/uhdmcmp_movers.txt](evidence/sweeps/uhdmcmp_movers.txt)); every probe case stays uhdm-cmp EQUAL (the probe stage fails on any that does not) |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **`MOVERS: 22 / 2560`**, PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560 flagged; **22 of 22 predicted by name** (section 5) |
| canaries | | surelog `ok=37 changed=15` (exactly the 15 canary rows among the conversions and changes above); uhdm2rtlil `ok=16 changed=0`; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS |

**The four row-mode conversions** (fresh rows, NOT written to `results/`):

    ClassTypeParam,default,CMP_EQUAL,,,equal     was differ:endline(17)   § unitClassTdSpecAtName202 + § unitClassTdEndAtInit202 + § classSpecExprArgUnlocated202
    ClassTypeParam,testflags,CMP_EQUAL,,,equal   was differ:file(30)
    int_types,default,CMP_EQUAL,,,equal          was differ:fullname(82)  § tfSigningSpanFollowsCompilePath200 + § defGenInitRhsKeepsParent200 (uhdm2rtlil)
    int_types,testflags,CMP_EQUAL,,,equal        was differ:fullname(82)

**The 18 surelog changes** are the table at the top (every one stays judge-equal). **The 14 probe conversions:** the
twelve of r11u200's lawB (r10earl109repro/g6_carrier109, r10rgg6repro/cells/{genfor_p2_n4, one_p2_n2, one_p2_n4,
one_p2_n4 _2ts, rec_p2_n4, two_p2_n4}_yes_typed_param, r10svs11repro/v3_arr, r10uvm70repro/a1_ret,
r10uvm97repro/g97_a1_selftd, g97_a4_plainclass, r10v97repro/v97_c1_mixedgroup) and two by § classSpecExprArgUnlocated202:
**r10sd1repro/b9_inline** (`differ:file(9)` -> EQUAL) and **r10uvm55repro/a1** (`differ:file(12)` -> EQUAL), both
predicted by the census (`classSpecExprArgUnlocated202:2` / `:4`). **The 13 probe changes** are r11u200's (twelve
r10rgg6repro cells `endcol(n)` -> `line(n-1)`, r10v78repro/v6_ndecl78 `fullname(3)` -> `fullname(2)`).

**Byte controls on the earlier passes' evidence** ([evidence/grids/bytectl_earlier_passes.txt](evidence/grids/bytectl_earlier_passes.txt),
`drivers/bytectl.sh`, pristine vs law with traces, the probe command line): 1418 case dirs of r11u118repro,
r11v11u118repro, r11u119repro, r11u120repro, r11v120repro, r11u124repro, r11v124repro, r11u131repro, r11v131repro,
r11u186repro, r11u188repro, r11u191dec, r11u193repro, v11u193repro, r11u194verify, r11u196repro, v11u196repro,
r11u199verify, r11u200dec: 69 move, **every one with a firing of a law of this pass** (0 unexplained; 5 dirs write no
database in either binary: multi-file cases this driver runs single-file), all 118 / 119 / 120 / 124 / 131 cases
byte-identical. The movers outside r11u200dec judged pristine -> law: 6 NOT_EQUAL -> EQUAL (r11u196repro EN/e03,
MG/ma03, r11v124repro pv/v07_class, v11u196repro MG/g05, and r11u200dec K/k04, k06), r11u191dec Q/q01 NOT_EQUAL ->
`type(1)`, the rest unchanged verdicts; **none leaves EQUAL** (MG/m09, m11, ma01, ma06, v11u196 g03, r11u194 Z/z01 do
not move at all under the law binary).

## 5. Movers, predicted by name

The firing census (`drivers/census.sh`: the law binary with `R11U200_TRACE` and `R11U202_TRACE` over every corpus
row-mode but the fenced four and every probe case, BEFORE the law sweep; `drivers/censum.py`) predicted 123 corpus
row-modes and 156 probe cases; the summary was frozen `chmod 444` in
[evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt) at the time recorded in
[frozen_at.txt](evidence/census/frozen_at.txt), before `/tmp/r11u202_sL` started. The trace sits on every branch that
writes (the respan helper traces both branches; the port-packed and signing laws trace every entry they reach), so the
prediction is a superset.

**22 of 22 movers predicted by name; 0 moved-not-predicted; 101 predicted-not-moved.** Attribution
([evidence/sweeps/byteverify_law_vs_pristine.txt](evidence/sweeps/byteverify_law_vs_pristine.txt),
[byteverify_law_vs_l200.txt](evidence/sweeps/byteverify_law_vs_l200.txt)): the 20 movers of `l200.bin` are
r11u200's own twenty (BuildUVMPkg, Earlgrey_0_1, MiniAmiq, Scr1SvTests, SeqDriver, SimpleUVM, SVSwitch, UnitElabBlock
d/t; Rggen, Scoreboard d; int_types d/t); the laws of section 3 add ClassTypeParam d/t (the conversion) and move 9
UVM databases further (BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM d/t, Scoreboard d) by § classValueParamIntSigned202
alone: `uvm_bit_rsrc::N` / `uvm_byte_rsrc::N`'s typespec gains its parameter parent, golden's shape; their strict
cells and order-blind distances are identical to `l200.bin`'s.

**The UVM counts that grow** (the brief's caution (c)): the first record of each row is unchanged by the law binary
(MiniAmiq `#899 file enum_typespec uvm_pkg::uvm_severity` uvm_globals.svh 271:61 against ours uvm_object_globals.svh
242:1; SeqDriver `#5387 fullname ref_obj i` `...print::space.substr::i` against `...print::i`; SimpleUVM `#458` /
Scoreboard `#466 fullname ref_typespec` `UVM_MACRO_NUMFLAGS` against `uvm_pkg::UVM_MACRO_NUMFLAGS`; BuildUVMPkg
`#3245 line int_typespec uvm_action` 9704:72 against 8075:9), and the walk diverges later: r11u200 section 3f
located the old divergence at `get_event_pool` (§ classTdRetSharesTypedefTs200 removes it), after which more records
are compared. The order-blind distance (section 6) falls on every UVM row.

## 6. Determinism and the UVM distance

**Order-blind distance to golden** (ours-not-in-golden strict records, depth dropped; `drivers/uvmdist.sh`,
[evidence/sweeps/uvm_orderblind_distance.txt](evidence/sweeps/uvm_orderblind_distance.txt)):

| row-mode | pristine | r11u200 alone | law | |
|---|---|---|---|---|
| MiniAmiq d/t | 6886 | 6789 | 6789 | -97 |
| SeqDriver d/t | 5472 | 5380 | 5380 | -92 |
| SimpleUVM d/t | 2312 | 2228 | 2228 | -84 |
| Scoreboard d | 1736 | 1653 | 1653 | -83 |
| BuildUVMPkg d/t | 954 | 852 | 852 | -102 |

**Determinism** (`drivers/det.sh`: each binary three times CONCURRENTLY per row-mode with the pristine sweep's command
line and cwd; `drivers/detob.sh` dumps every draw of a row-mode that gave more than one database and compares the
SORTED dumps, ids and the path header dropped; [evidence/determinism/](evidence/determinism/)):

| row-mode | pristine: distinct databases (of 3) | order-blind dump lines | law: distinct databases (of 3) | order-blind dump lines |
|---|---|---|---|---|
| Earlgrey_0_1 default | **1** | - | **1** | - |
| Earlgrey_0_1 testflags | **1** | - | **1** | - |
| MiniAmiq d / t | 2 / 2 | 0 / 0 | 2 / 3 | 0 / 0 |
| SeqDriver d / t | 2 / 1 | 0 / - | 1 / 2 | - / 0 |
| SimpleUVM d / t | 1 / 1 | - | 2 / 1 | 0 / - |
| Scoreboard d | 3 | 0 | 1 | - |
| BuildUVMPkg d / t | 1 / 2 | - / 0 | 1 / 1 | - |

Every draw of more than one database is a serialization-order draw whose dumps are identical line for line (0
order-blind lines), in both binaries: the value coin stays CLOSED (§ queueRetTwinDynShape191) and **no law of this pass
adds a coin**; Earlgrey_0_1 stays one database per mode per binary. The raw draw counts vary between runs of the same
binary (pass 196 saw MiniAmiq testflags draw two, r11u200 three) and are not a property of either binary.

## 7. Residues, ranked, and the sister-ground faces

Ranked by the rows they hold, then by downstream weight.

1. **The UVM rows** (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg: 9 row-modes). First records: MiniAmiq
   #899, the `uvm_severity` enum typedef moved by class-method and outside writers (UhdmExporter, the
   § tfArgClassMethodOrder176 mover: r11u196's R1, not attempted); SeqDriver and BuildUVMPkg's `space.substr::i`
   names (a method call's receiver scoping its argument references: **ExprEmit**, ground A); SimpleUVM and
   Scoreboard's package-parameter ref_typespec full name `uvm_pkg::UVM_MACRO_NUMFLAGS` where golden stores
   `UVM_MACRO_NUMFLAGS` (the package parameter listing, **ParamEmit**, ground A); BuildUVMPkg #3245, the `uvm_action`
   int typedef copy at a use (N0039, ground B: r11u196's R5, not attempted). The ground-B families N0067 / N0068,
   N0180, N0158, N0177, N0184 were not attempted.
2. **UnitElabBlock d/t** `file(2)` / `file(1)`: the implicit `logic_net work@mod.hold` minted for a block-local
   `logic hold;` hidden by the Verilog-mode lexer carries `top.v` where golden's carries no file: the mint is
   **ExprEmit**'s `vlogHiddenBlockVars` branch, which does not call `noteImplicitNetMint131` (the other three implicit-net
   mints do: § implicitNetMintNoFile131); with that one call the row reads the golden file field. Not measured
   (ground A).
3. **SVSwitch d/t** `fullname(2)`: pair A's `new[...]` size names (r11u200's newArrayArgPathElemsStripped200,
   ExprEmit): r11u200 measured the composition converting both modes.
4. **Scr1SvTests d/t** `endcol(11)`: pair A's reduced-bound location (r11u200's unitBoundFoldAtLeftOperand200,
   ParamEmit halves) then the Surelog binding defect of r11u200 section 3d (`type(1)`, report only).
5. **arb_idx_cast d/t** `endline(2)` (#360 / #384): golden's type parameter default typespec object
   (`logic [IdxWidth-1:0]`, 8:40) is the one the module variable `idx_t [2**NumLevels-2:0] index_nodes` uses, and
   Surelog's populate of that variable moves its END to the end of the FIRST dimension of the last such declaration
   (grid [cases/TD](cases/TD): a01 3:10, a03 two uses: the second's first dimension 4:10, a04 an unpacked dimension
   alike, a02 no dimension: unmoved). The cast sites that read it are stage-1 in a01-a04 (a pair-A face in the
   definition-view cast), so no law was landed; site `makeTypeParamDefaultTs` (TypeEmit, § typeParamDefaultBoundNoReduce20).
6. **R5 — emitClassTsParams lists every formal** where Surelog lists the WRITTEN ones (CT/c17, UV/u06): a module
   variable `m #(8) h` of `class m #(int W, type T)` lists T in ours, nothing in golden; the respan helper keeps the
   old listing. The transcription in `emitClassPropSpecParams163` has the right loop; switching the module-variable
   site to it needs the pa-file rule of § classSpecPaNoFile152 measured on both builders.
7. **R6 — a `= null` class variable initializer** (CT/c21, UV/u08): golden's `constant 0` (UINT, size 64, const type
   11) is absent in ours (stage 1).
8. **R3 — a class value parameter's unpacked dimension** (CP/p04, MG/ma07, m12): golden folds `[W]` to a 64-bit
   constant typed by a COPY of the parameter's int typespec, ours 32-bit with a fresh int typespec.
9. **R7 — a generate localparam fold in a generate-variable initializer** (GI/g05): golden `UINT:2` size 8 const type
   9, ours the signed-decimal `INT` branch (ModuleEmit's pendingGenVarInit localparam branch).
10. **R8 — an unnamed gen-case branch's variable** (R0/v02) named `.a` in ours, `a` in golden (the definition view).
11. **R9 — `sub #() u(...)` beside `sub u(...)`** (R0/q02): the pre-existing `textMultiParamDefs` rule reads `#()` and
    no override as two override texts and drops both ref_modules; golden keeps them.
12. **InterfaceStructMemberPort d/t** `fullname(6)`: golden re-parents the modport view's `req` / `trn` at the
    connection OPERATION `sub.req.wen & sub.trn` of the child instance and names the operation's references through
    the child's port (`work@top.w.u.sys_wen.wen`); a small grid ([cases/IM](cases/IM)) diverges structurally before
    the naming (f01, f03: a ref_obj where ours has the hier_path), so it is decoded only this far (ModuleEmit,
    § modportExprPort's site).
13. **r11u199 N6** (c06, DIVERGENT: the elaborated `$signed` taking the net's typespec) and **N5** (x06, a Surelog
    defect): not attempted, as r11u200 left them.
14. Pass 193's residues (pm01, pm07, CL/s12 + bc09, tf07 / uc22, the unsized detector, nested module arrays), r11u196's
    R4 (SF/s03), R6 (evalFunc hex / pattern actuals), R7 (`--elabuhdm` class_defn full names), R8 (MG/m10), R10
    (named-argument calls), cfg_func_width_loop and struct_param_func_config's B halves, Earlgrey's #90097 and the
    evaluator fold decision of pass 195's residues: not attempted this pass.

**Sister-ground faces met on the way** (stopped at the decode, with the call site): UnitElabBlock's file (ExprEmit
`vlogHiddenBlockVars` branch, § implicitNetMintNoFile131); the `$bits` generate cases' elaborated fold (ExprEmit,
r11u200's genBlockBitsKeepsSelect200 A half); R0/u01's $unit initializer constant (ParamEmit, r11u200's
unitBoundFoldAtLeftOperand200 A halves); the UVM `space.substr::i` names (ExprEmit) and the package-parameter
ref_typespec full names (ParamEmit); GI/g02's pristine definition-view bit-select span came from TypeEmit, fixed here.

## 8. Files

* `cases/`: CT (the $unit class typedef and module-variable specializations: § unitClassTdSpecAtName202,
  § unitClassTdEndAtInit202, § classSpecExprArgUnlocated202), CP (§ classValueParamIntSigned202), N2
  (§ modPkgGenericSpecNamedBare202), UV (§ modSpecValueArgSpanAtName202 and neighbours), GI
  (§ genVarInitOuterRefUnbound202, § defGenInitBitSelAtIndex202), K (§ modGenericClassListedAtDefault200, the
  listing order), R0 (fresh re-verification cases of the r11u200 laws, each naming its law), TD (arb_idx_cast's
  decode, § typeParamDefaultBoundNoReduce20's site), IM (InterfaceStructMemberPort's decode, § modportExprPort's site).
  Every case names its law on its first line.
* `drivers/`: `env.sh` (pins + fence), `case.sh` (judge one case as check_probe does), `grid.sh`, `compose.sh`
  (the class-listing composition), `bytectl.sh` (byte controls with traces), `switches.sh` (each switch alone),
  `census.sh` + `censum.py` (the firing census), `sweep.sh`, `bvmirror.sh`, `uvmdist.sh`, `det.sh` + `rowrun.sh`
  (determinism), `dscase.py` (the downstream gate's `one()` on a case), `spantab.py`, `obdist.sh`.
* `evidence/`: `grids/` (own and r11u200dec grids with the OFF column, the composition, the byte controls),
  `switches/`, `census/` (the frozen prediction), `sweeps/` (the three gate summaries, byteverify, uhdm-cmp on the
  movers, canaries and the binary audit, the UVM distances), `downstream/`, `determinism/`.
