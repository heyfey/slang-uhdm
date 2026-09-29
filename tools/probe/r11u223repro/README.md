# r11u223: pass 223, the module/type ground: the scalar typedef formal's own copy at its type token (the UVM_FILE head of the UVM rows), the fixed-then-associative array element, and the elaborated `$size` crash and sizing

**Base** `896ec643` (branch matrix-1.87). Production files touched: `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`,
`src/TypeEmit.cpp`, `uhdm_main.cpp` and a new header `src/R223.h` (the switches, the trace, the formal registry);
nothing in ExprEmit.cpp, EmitHelpers.h, StmtEmit.cpp or ParamEmit.cpp. Law names are written `§ name` in the source
and `law name` here; a probe case is called a case. The four slang-fenced tests are never named here: every driver
reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed (section 10).

## 0. Verdicts

| target | before (base `896ec643`) | after | law(s) |
|---|---|---|---|
| item (1): `typedef int UVM_FILE`, the first record of every judge-equal UVM row-mode of this ground | `file(7)` / `file(56)` / `file(32)` headed by `int_typespec UVM_FILE` at the declaration | **cleared on all seven** (the formal's own copy at its type token); the scalar-typedef formal family closes corpus-wide (5942 records toward golden, 0 lost) | tfArgScalarTdWriter223, tfArgScalarTdExportFirst223 |
| MiniAmiq d/t | `differ:file(7)` | **`differ:line(2)`** (next head: `UVM_SEQ_ARB_TYPE`, residue 1) | tfArgScalarTdWriter223 |
| SeqDriver d/t | `differ:file(7)` | **`differ:line(2)`** (same next head) | tfArgScalarTdWriter223 |
| SimpleUVM d/t | `differ:file(56)` | **`differ:file(42)`** (next head: `this_type` of an out-of-body formal, residue 2) | tfArgScalarTdWriter223 |
| Scoreboard d | `differ:file(32)` | **`differ:file(18)`** (same next head) | tfArgScalarTdWriter223 |
| BuildUVMPkg d/t | `differ:line(31)` | `differ:line(31)` (its head is `this_type`; 406 records toward golden each) | tfArgScalarTdWriter223 |
| item (1): a `$unit` class method formal (pass 219's x03) | enum alias: `line` | unchanged: an ENUM alias relocation, not the scalar family (residue 4); a `$unit`-class SCALAR formal converts (F/f23) | - |
| item (2): the elaborated `$size` crash on an unpacked array with an unsized inner dimension | rc 139 (v11u219 S/s01, s01b, s01c; own S/s01, s02) | **rc 0 on all five**: the associative shape gets golden's element and golden's value `UINT:32`; the dynamic / queue shapes decline cleanly (Surelog fails on them) | fixedOuterAssocInnerReg223, unsizedInnerSizeDeclines223 |
| item (2): golden's generic-handler `$size` values | elaborated view: golden's value, size 64 at the call | **size and location follow golden** (masked, sized to the net, location-less): v11u219 S/s08 elaborated **stage 1 -> STRICT_EQUAL**, own S/s03 and S/s04 elaborated stage 1 -> EQUAL; the parse view keeps the call (residue 5) | ndaAdjSizeFoldSized223 |
| item (2): sized and based range bounds | stage 1 | decoded, not written (residue 6) | - |
| downstream | 803 / 66 / 2 / 0 | **803 / 66 / 2 / 0, verdict diff 0**; 0 of 805 slang lanes move; own case C/c04 EQUIVALENT -> IDENTICAL | - |

**No corpus row-mode converts** (every UVM row still carries the enum-writer and `this_type` families, section 11).
**Probe: 4 cases convert** (r10uvm125repro/g125_b_shapes, g125_d_homes, r10uvm35repro/t47a, t47b), 2 change
(r10uvm36repro/t48a `line(10) -> name(2)`, t48c `line(8) -> fullname(3)`: the line records cleared, the next record a
pre-existing one), none regress.

**Gates** (`tests/sweep.sh --jobs 3` with the final binary, against the committed baselines): **probe regressions=0
conversions=4 changes=2 (EQUAL 3436 / STRICT_NOTEQUAL 651); surelog regressions=0 conversions=0 changes=7;
uhdm2rtlil 0 / 0 / 0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict diff 0 against
the baseline and against the pristine sweep.** Byte movers 25 (9 corpus row-modes, 16 probe cases) = the frozen
prediction exactly. Away census 0 records lost chain-keyed; the flat key's 234 "lost" are every one paired in place
with golden's record (section 6).

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u223_bin` before measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `b47000e7909cadf602db20c266431038` | the worktree at `896ec643`, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| **`law_d5`** | **`2a3d1e1b815930691a1fd6a5d83c660d`** | **the final binary = `896ec643` + this pass's src diff** (a rebuild of the worktree after the last, comment-only edit reproduces it byte for byte) |
| `law` (= `law_d4`) | `0559133d5c1bfe8022a3f3b9ae339dd7` | the same laws with the formal registry grown by `push_back` (not reserved): the census binary and the first law sweep; retired for the determinism finding of section 9 |
| `law_d1`, `law_d2`, `law_d3` | `5def30e0…`, `ba164051…`, `dbda7147…` | drafts (d1: the formal law alone; d2: + the DPI-export refinement; d3: + the associative element and the adjuster decline); grid and UVM measurements only |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build (not edited) |

Sweeps (`tests/sweep.sh --jobs 3`, 15-character workdirs, every `slang:` line of every `cmds.txt` naming its sweep's
binary, 3273 of 3273 each): pristine `/tmp/r11u223_wP`, the first law sweep `/tmp/r11u223_wL` (`law`), **the final
sweep `/tmp/r11u223_wF` (`law_d5`)**. Both law sweeps read the same verdicts in every stage and the same 25 byte
movers; `law_d5`'s databases differ from `law`'s only in the order of the symbol table's tail on some UVM rows
(section 9); every number below is the final sweep's unless it says otherwise. The firing census (the prediction,
section 5) ran `law` with `R11U223_TRACE` over `/tmp/r11u223_cen` (the firing conditions are the same in both
binaries). Every sweep's EXIT=1 is the tests/LAWS.md staleness alone (this
directory and the new law names; the patch carries the regenerated file); every compare stage reads regressions=0.

## 2. Item (1): the UVM_FILE head — decoded, and it is not a relocation

**The head at the base** (build/uhdm-strictcmp on the pristine sweep, [evidence/heads/](evidence/heads/)): all seven
judge-equal UVM row-modes of this ground (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d; Scoreboard t is
SLANG_REJECT) start with the same family, `file(7)`, `file(56)`, `file(32)`:

```
#15390 file   (SimpleUVM default; MiniAmiq #15320, SeqDriver #15303, Scoreboard #15398)
  A: 5 int_typespec UVM_FILE   uvm_root.svh           348 39 348 47     <- golden
  B: 5 int_typespec UVM_FILE   uvm_object_globals.svh 313  9 313 12     <- ours
#18450 file
  A: 5 int_typespec UVM_FILE   uvm_component.svh     2250 61 2250 69
  B: 5 int_typespec UVM_FILE   uvm_object_globals.svh 313  9 313 12
```

`typedef int UVM_FILE;` (uvm_object_globals.svh 313) is read by class-method formals (`uvm_root::...(UVM_FILE file)`,
`uvm_component::set_report_*_file(..., UVM_FILE file)`); golden holds one int_typespec per formal, each at that
formal's type identifier, where ours held the declaration's span.

**Surelog's rule** (third_party/Surelog/src/DesignCompile/CompileStmt.cpp `CompileHelper::compileTfPortList`, and
CompileType.cpp `CompileHelper::compileDatastructureTypespec`): compileTfPortList compiles each formal's data type with
`compileTypespec(component, fC, type, ...)` and then runs `fC->populateCoreMembers(type, type, ts)` on the object that
comes back. For a name resolving to a `TypeDef` whose actual is a `SimpleType` (a typedef of a builtin type: `int`,
`int unsigned`, `integer`, `byte`, `shortint`, `longint`, `bit`, `bit [3:0]`, `logic [7:0]`), compileDatastructureTypespec
returns a FRESH `clone_tree` of the typedef's typespec with a `Typedef_alias` back at it, so the populate writes the
clone's span and vpiFile (the formal's type identifier) and the typedef keeps its own. An enum, struct or union typedef
and a typedef of a typedef return the typedef's own object instead, which the populate MOVES (the relocation family of
§ tfArgClassMethodOrder176 and its relatives); a scalar typedef is not in that family, which is why the formal-writer
model never had to consider it. The return type and body locals are compiled elsewhere and keep the declaration span
(golden f17).

**Our side**: LAW S (TypeEmit `bareScalarTypedefVarTs`, the bare aliased per-declaration copy of a package scalar
typedef) binds ONE memoized copy per listing object, at the typedef's span, to every variable, io_decl and member; the
logic-vector formal branch of TaskFuncEmit already minted a per-formal clone at the token (§ tfFormalTdCloneFile196), so
`logic [7:0]` formals were right (golden f03 STRICT_EQUAL at the base) and every other builtin kind was not.

### 2.1 § tfArgScalarTdWriter223 (switch `R11U223_SCALARTDTOK_OFF`)

TaskFuncEmit (`emitTaskFuncs`, the ANSI formal and the pure virtual prototype's formal) records every formal whose data
type is a bare type identifier (`NamedType` over an `IdentifierName`, not a DPI import, not a body-style `input x;`
declaration) with the identifier's range (`src/R223.h formalTdTok223`, a vector in emission order). A design-final
pass in `UhdmExporter::exportDesign` (placed before § tfArgTypedefLastWriter146's early returns, so it runs on every
design) re-points each recorded formal whose final typespec is a bare-named, aliased per-declaration copy of an
int / integer / byte / shortint / longint / bit / logic typespec at a copy of that final object (every field shared:
signing, ranges, element, name, instance, alias target) carrying the identifier's span and file in our location model;
a formal already there (the logic branch) is left alone. Copy versus share is outside the strict contract
(GOLDEN_EQUIVALENCE.md, "Typespec identity is canonicalised").

### 2.2 § tfArgScalarTdExportFirst223 (switch `R11U223_SCALARTDEXP_OFF`), found by the grid

A subroutine whose `export "DPI-C"` declaration PRECEDES its definition in the same scope keeps the typedef's LISTING
object on its formal in golden (f21: `p::UVM_FILE` 3:11; the export's prototype takes the ports first, the decode of
§ tfArgDpiExportFirstNoWrite153v), while an export written after the definition gets the token clone (f24: golden
`UVM_FILE` 4:20-4:28). The first draft moved f21's copy to the token (a line field away from golden on a record whose
name was already wrong); the refinement does not record such a subroutine (bytes of f21 back to pristine).

### 2.3 The grid (cases/F, both views; [evidence/grid_law.tsv](evidence/grid_law.tsv), [evidence/switches_F.txt](evidence/switches_F.txt))

| case | shape | pristine | law |
|---|---|---|---|
| f01 | package class method, `UVM_FILE file` | line | **EQUAL** (both views) |
| f02 | two classes, a package parameter of the typedef | stage 1 | stage 1 (bytes move: its formals) |
| f03 | `logic [7:0]` typedef (the control: the logic branch) | EQUAL | EQUAL, bytes same |
| f04 | `bit` typedef and a typedef of a typedef | stage 1 | stage 1 |
| f05 | package function | line | **EQUAL** |
| f06 | `bit`, `byte`, `integer`, `bit [3:0]` (with `input`) | line | **EQUAL** |
| f07 | typedef of a typedef only | stage 1 (golden's definition listing omits the chain typedef) | stage 1, bytes same |
| f08 | `$unit` typedef, module function | stage 1 (unsupported predefined target) | stage 1, bytes same |
| f09 | class task: `output`, `ref`, `input`, bare; int, `int unsigned`, longint, shortint | line | **EQUAL** |
| f10, f11 | module-local and class-local scalar typedefs | stage 1 | stage 1, bytes same (not package typedefs: LAW S does not reach them) |
| f12 | extern prototype and out-of-body definition | line | **EQUAL** (parse); elaborated `fullname` (the out-of-body function's own full name, the next record) |
| f13 | package-qualified formals `p::UVM_FILE` (not recorded) | line | line, bytes same (residue 3) |
| f14 | unpacked `UVM_FILE files[]` and queue `ref UVM_FILE q[$]` | line | **EQUAL** |
| f15 | a formal inside a macro expansion, a multi-line formal | endcol | endcol (the macro formal's column follows our io_decl's macro model: residue 6) |
| f16 | a class of an importing package extending the home class | line | **EQUAL** |
| f17 | package function with a default, a return and a local of the typedef, a package task | line | **EQUAL** (return and local stay at the declaration, as golden) |
| f18, f19, f22, f23 | module function, interface function, module-scope class, `$unit` class | line | **EQUAL** |
| f20 | program task | stage 1 | stage 1 |
| f21 | DPI import + export BEFORE the definition | name | name, bytes same (§ tfArgScalarTdExportFirst223) |
| f24 | export AFTER the definition | stage 1 | stage 1 (golden writes the token; ours now too) |
| f25 | two files (`args`), the same declarator position in both | line | **EQUAL** |
| f26 | a header with a typedef formal included in two modules | stage 1 | stage 1 |
| f27 | CRLF, a formal on its own line | line | **EQUAL** |
| f28 | formals written in a macro body from an included header | file | **EQUAL** |
| f29 | a pasted type name `` `TY(file) `` | col | col (the typespec now at golden's 7:25-7:31; the io_decl column is the macro model, residue 6) |

**Grid totals** ([evidence/grid_law.tsv](evidence/grid_law.tsv), drivers/grid.sh: pristine, law, and the law binary
under `R11U223_OFF`, per case-view): 82 case-views (F 58, C 16, S 8); **31 enter EQUAL** (F 29, S 2), **none leaves
EQUAL**, `R11U223_OFF` gives pristine bytes on all 82. Per law ([evidence/switches_F.txt](evidence/switches_F.txt),
[switches_C.txt](evidence/switches_C.txt), [switches_S.txt](evidence/switches_S.txt), drivers/switches.sh):
`R11U223_SCALARTDTOK_OFF` restores pristine bytes on all 58 F case-views and moves none of C; `R11U223_SCALARTDEXP_OFF`
changes f21 only (both views: the refinement's own case); `R11U223_ASSOCREG_OFF` restores pristine on every C
case-view and moves no F case-view.

## 3. Item (2): the elaborated `$size` crash, the associative element, and golden's generic-handler value

### 3.1 The crash, found with gdb on our own case

`gdb` on `pristine --elabuhdm` of tools/probe/v11u219repro/cases/S/s01c_assoc_inner (not a corpus source):

```
#0 UHDM::ExprEval::size(...)                        <- array_var->Variables()->at(0), Variables() null
#1 UHDM::ExprEval::reduceExpr(...)                  <- the `$size` branch: size(object) for an array_var argument
#2 UHDM::UhdmAdjuster::updateParentWithReducedExpression
#3 UHDM::VpiListener::listenSys_func_call ... realMain (uhdm_main.cpp, the --elabuhdm adjuster)
```

UHDM's ExprEval::size (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp, `case uhdmarray_var`) reads the
element variable unguarded. Golden's shapes (cases/C, `uhdm-dump` of the elaborated instance):

| case | declaration | golden vpiArrayType | golden vpiReg | ours at the base |
|---|---|---|---|---|
| c01 | `int ma [4][int]` | 3 | `int_var` | none |
| c02 | `int md [4][]` | 2 | none | none |
| c03 | `int mq [4][$]` | 4 | none | none |
| c04 | `logic [7:0] ms [2][string]` | 3 | `logic_var` | none |
| c05 | `int m5 [2][int][3]` | 3 | `int_var` | none |
| c06 | `int m6 [2][3][int]` | 3 | `int_var` | none |
| c07 | `int m7 [2][][int]` | 2 | none | none |
| c08 | `int m8 [2][int][]` | 3 | `int_var` | none |

The rule: the element exists when the FIRST unsized dimension is associative, whatever fixed dimensions lead it; a
dynamic or queue first unsized dimension behind a fixed one has none (and Surelog itself aborts on `$size` of those,
v11u219 s01 s01b: SURELOG_FAIL). Leading-unsized shapes already carried it.

* **§ fixedOuterAssocInnerReg223** (TypeEmit `emitDynArrayVar`, switch `R11U223_ASSOCREG_OFF`): the element reg for a
  leading-fixed shape whose first unsized dimension is associative (the initializer carriers stay with the
  leading-unsized shape, unmeasured otherwise). The reg blocks of c01, c04, c05 read identical to golden's in
  `uhdm-dump`. Every C case stays stage 1 on the fixed `[4]` bound (golden keeps `4-1` as an operation, ours the
  folded `UINT:3`: ground A's range-size family), but downstream C/c04 goes **EQUIVALENT -> IDENTICAL**.
* **§ unsizedInnerSizeDeclines223** (uhdm_main.cpp, switch `R11U223_SIZEDECLINE_OFF`): for the adjuster's run only,
  every array_var without an element holds a placeholder element of a kind ExprEval::size does not size (a
  `chandle_var` outside the serializer: its default branch sets invalidValue, and updateParentWithReducedExpression
  returns on an invalid value), removed right after. The fold declines and the call stays; no written byte can come
  from the placeholder. S/s02 (`int md [4][]`, `int mq [2][$]`) and v11u219 s01, s01b: rc 139 -> 0 in the elaborated
  view (Surelog fails on them, so no golden).
  *Verification note (tools/probe/v11u223repro, section 3):* the placeholder as first landed did NOT decline:
  ExprEval::size sizes the element's typespec, which the placeholder lacked, so the adjuster wrote an invented
  `UINT:0`; § sizeDeclineTsInvalid223v gives the placeholder a chandle_typespec, and the call now stays.
* **§ ndaAdjSizeFoldSized223** (uhdm_main.cpp, switch `R11U223_ADJSIZE_OFF`): a net declaration's whole-initializer
  `$size` call that § ndaSizeQueryFold216's reach declines (§ sizeReachFollowsWalker219v) is folded by the adjuster to
  golden's VALUE (UHDM's generic handler: the element size times the last range) but at the call's span with size 64;
  Surelog folds it in writeCont_assign and adjustSize masks and sizes it to the net, location-less, parented at the
  assignment (golden v11u219 s08 `UINT:2` size 8, no span). Recorded after the elaborator (the objects the adjuster
  sees, in UhdmId order), applied after the adjuster to the constant that replaced the call: the shape
  § ndaSizeQueryFold216 writes itself. **v11u219 S/s08 elaborated stage 1 -> STRICT_EQUAL**, own S/s03 and S/s04
  elaborated stage 1 -> EQUAL, v11u219 S/s04 elaborated 30 -> 16 cmp lines (its next head is `$size(ps, 1)` on a packed
  struct, a call golden keeps with the module's typespec stamp: ground A). The parse view keeps the call (residue 2:
  transcribing ExprEval's generic handler into the parse view).

| case | view | pristine | law | law's switches |
|---|---|---|---|---|
| S/s01 (`$size(ma)`, `int ma [4][int]`) | elaborated | **rc 139** | stage 1, `UINT:32` sized 8 location-less as golden (the next head is the `[4]` bound) | ASSOCREG_OFF: the decline keeps it alive (other bytes); SIZEDECLINE_OFF: law bytes (the reg exists) |
| S/s02 (dynamic, queue inner) | elaborated | **rc 139** | rc 0 (SURELOG_FAIL: no golden) | SIZEDECLINE_OFF: rc 139 again |
| S/s03 (`$size(bp)`, `bit [3:0][1:0]`; `$size(lp)` into a 4-bit net) | elaborated | stage 1 | **EQUAL** | ADJSIZE_OFF: pristine |
| S/s04 (`$size(ea, 2)`, enum array, 4-bit net) | elaborated | stage 1 | **EQUAL** | ADJSIZE_OFF: pristine |
| v11u219 S/s08 | elaborated | stage 1 | **STRICT_EQUAL** | |
| v11u219 S/s01c | elaborated | **rc 139** | stage 1 | |
| v11u219 S/s01, s01b | elaborated | **rc 139** | rc 0 (SURELOG_FAIL) | |
| every other v11u219 and r11u219 S case | both | as pristine | bytes same | |

No corpus row-mode runs these shapes: a wrapper recording every exit code over the 211 elaborated corpus row-modes
without a database at the base read `rc 3` 208 times, `rc 2` twice, `rc 1` once, never a signal
([evidence/rc_elab_nodb.txt](evidence/rc_elab_nodb.txt)); the census recorded no firing of the associative element or
the sized fold in either corpus or the probe set.

## 4. The gates (final binary `law_d5`, sweep `/tmp/r11u223_wF`; [evidence/final/](evidence/final/))

| gate | result |
|---|---|
| (1) build | `pristine` = the main tree's md5 `b47000e7…`; `law_d5` `2a3d1e1b…` (a rebuild of the worktree reproduces it) |
| (2) probe | **regressions=0 conversions=4 changes=2**, EQUAL 3436 / STRICT_NOTEQUAL 651 of 4087 (baseline 3432 / 655) |
| (3) surelog | **regressions=0 conversions=0 changes=7** (the seven UVM row-modes of section 0); the pristine sweep read two environment CHANGEs of its own (CoresSweRV and CoresSweRVMP default SURELOG_FAIL -> TIMEOUT, golden generation under memory load), the law sweep none |
| (3) uhdm2rtlil | **regressions=0 conversions=0 changes=0** (1598 CMP_EQUAL + 8 STRICT_NOTEQUAL) |
| (4) downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**; verdict diff 0 against results/downstream_uhdm2rtlil.csv and 0 against the pristine sweep; slang-lane databases: 0 of 805 move |
| (5) uhdm-cmp | 0 lines on all nine moved corpus row-modes (rc 0); every moved probe case is judge-equal by the probe gate |
| (6) byteverify | tools/probe/r11v75repro/byteverify.sh on hard-link mirrors without the 8 fenced row-mode databases (drivers/bvmirror.sh, `fenced_skipped=8` per side): PATH_SETS_IDENTICAL (2560), **MOVERS 9 / 2560**, SELFCHECK 2559 / 2560 flagged |
| canaries | tools/probe/r11u107repro/canaries.sh: surelog ok=47 changed=5 (SimpleUVM d/t, SeqDriver d/t, Scoreboard d: the claimed changes), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` (surelog) PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` (uhdm2rtlil) PASS |
| binaries | all 3273 `slang:` lines of the pristine sweep name `/tmp/r11u223_bin/pristine`, all 3273 of the final sweep `/tmp/r11u223_bin/law_d5` (and all 3273 of the first law sweep `/tmp/r11u223_bin/law`) |

The fresh csv rows of the changed row-modes (none converts):

```
MiniAmiq,default,STRICT_NOTEQUAL,differ:line(2),,differ:line(2)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:line(2),,differ:line(2)
SeqDriver,default,STRICT_NOTEQUAL,differ:line(2),,differ:line(2)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:line(2),,differ:line(2)
SimpleUVM,default,STRICT_NOTEQUAL,differ:file(42),,differ:file(42)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:file(42),,differ:file(42)
Scoreboard,default,STRICT_NOTEQUAL,differ:file(18),,differ:file(18)
```

and the four probe conversions (`results/golden_probe.csv` untouched):

```
r10uvm125repro/g125_b_shapes,EQUAL,,equal       (was STRICT_NOTEQUAL differ:line(4))
r10uvm125repro/g125_d_homes,EQUAL,,equal        (was STRICT_NOTEQUAL differ:line(4))
r10uvm35repro/t47a,EQUAL,,equal                 (was STRICT_NOTEQUAL differ:line(1))
r10uvm35repro/t47b,EQUAL,,equal                 (was STRICT_NOTEQUAL differ:line(1))
```

## 5. Movers, predicted by name before the law sweep ([evidence/census/](evidence/census/))

The firing census (drivers/census.sh: the law binary with `R11U223_TRACE` over every corpus row-mode but the fenced
ones, `--filter` built from `$FENCED`, and every probe case) wrote one trace file per process that fired, naming its
output database; drivers/predict.py turned them into the prediction, frozen before the law sweep
([prediction_frozen.txt](evidence/census/prediction_frozen.txt), md5 `49ac9f3d7b8acc66064cec3b13140d32`): **25 databases,
all by tfArgScalarTdWriter223** (4712 firings: surelog MiniAmiq d/t 650 each, SeqDriver d/t 650 each, BuildUVMPkg d/t
406 each, SimpleUVM d/t 398 each, Scoreboard d 398; 16 probe cases). The associative element, the adjuster decline and
the sized fold fired nowhere in either corpus or the probe set (the probe runs the parse view; the elaborated corpus
row-modes have no such shape, and none crashed at the base: section 3). The byte movers of the pristine and final gate sweeps
(drivers/movers.sh, [evidence/final/movers.txt](evidence/final/movers.txt)): **9 corpus row-modes and 16 probe
databases, exactly the prediction** (`diff` of the two name lists empty; the first law sweep read the same 25). Scoreboard default is the known storage coin
row; it is also a firing row, and its away census reads 0 lost.

## 6. The away-moved-record census ([evidence/away_canonical.txt](evidence/away_canonical.txt), drivers/awayall.py)

Every database whose bytes differ between the pristine and the final sweep (25; the first law sweep read the same
totals), walked with its golden by the gate's
comparator, each record keyed by its ancestor chain and flat (depth dropped):

* **chain-keyed: 0 lost, 5942 toward golden** (MiniAmiq d/t 776 each, SeqDriver d/t 862 each, SimpleUVM d/t 610 each,
  Scoreboard d 504, BuildUVMPkg d/t 406 each, the 16 probe cases 1-46 each);
* **flat: 234 "lost", every one paired in place (`flat_unpaired=0`)**: the record is the copy at the typedef's own span
  (`bit_typespec uvm_reg_addr_t uvm_reg_model.svh 73:10-73:31` under an io_decl, 47 on MiniAmiq; `logic_typespec
  w48_t` on t48a), which golden holds 0 times at those chains and elsewhere often; the law replaced it at each chain by
  golden's record;
* **positive control**: the census run reversed (law as OFF, pristine as ON) reads chain_lost=5942
  ([away_canonical_reversed.txt](evidence/away_canonical_reversed.txt)).

## 7. Downstream

The gate sweep: 803 / 66 / 2 / 0 with a verdict diff of 0, and not one slang-lane database of the 805 moves (the UVM
rows are not in the uhdm2rtlil corpus; no uhdm2rtlil test has a formal of a package scalar typedef the law moves). The
own cases through scripts/downstream_uhdm2rtlil.py's `one()` with each binary (drivers/dscases.py, a fresh
`GOLDEN_CACHE`; [evidence/ds_cases.txt](evidence/ds_cases.txt)): 34 IDENTICAL -> IDENTICAL, **C/c04 EQUIVALENT ->
IDENTICAL** (the associative element), 2 DIVERGENT and 1 STATUS_DIFF unchanged, 1 SURELOG_FAIL; C/c07 read
EQUIVALENT twice (pristine's first run, the final binary's) and STATUS_DIFF in five runs (pristine twice, `law` three
times): the Surelog lane crashes nondeterministically (`surelog_status CRASH`, uhdm2rtlil's own Surelog), our bytes are
the same on every binary (no law fires there). The table in the evidence is pristine against the final binary.
No case leaves IDENTICAL.

## 8. The UVM rows: first records and order-blind distance ([evidence/heads/](evidence/heads/), [uvmdist_*.txt](evidence/))

| row-mode | first record at the base | first record with the law | order-blind distance (drivers/uvmdist.sh) |
|---|---|---|---|
| MiniAmiq d/t | #15320 `int_typespec UVM_FILE` file uvm_object_globals.svh 313:9 (golden uvm_root.svh 348:39) | #24915 `enum_typespec uvm_pkg::UVM_SEQ_ARB_TYPE` line 1381:51 (golden 332:40) | 5941 -> **5238** |
| SeqDriver d/t | #15303 (same) | #24898 (same as MiniAmiq) | 4598 -> **3779** |
| SimpleUVM d/t | #15390 (same) | #26887 `class_typespec this_type` file uvm_sequence_library.svh 330:12 (golden uvm_algorithmic_comparator.svh 74:11) | 1544 -> **934** |
| Scoreboard d | #15398 (same) | #26895 (same as SimpleUVM) | 1105 -> **601** |
| BuildUVMPkg d/t | #26855 `this_type` | #26855 `this_type` (unchanged; 406 records toward) | - |

The object counts of every row are unchanged (the law replaces a record, it adds none). Pass 219 left MiniAmiq 6014,
SeqDriver 4700, SimpleUVM 1624, Scoreboard 1165 at its base; the base here (after r11u221) reads 5941 / 4598 / 1544 /
1105.

## 9. Determinism ([evidence/det_law.txt](evidence/det_law.txt) (final), [evidence/det_pris.txt](evidence/det_pris.txt), [evidence/det/det_law_unreserved.txt](evidence/det/det_law_unreserved.txt), drivers/det.sh)

Three concurrent harness runs per binary on Earlgrey_0_1 and the five UVM rows in both modes (drivers/det.sh), plus
direct concurrent draws ([evidence/det/](evidence/det/), the object and symbol listers drivers/tool/idlist.cpp and
symlist.cpp):

| row-mode | pristine (3 draws) | `law` unreserved (3 draws) | **`law_d5` final (3 draws)** |
|---|---|---|---|
| Earlgrey_0_1 d/t | 1 hash each | 1 hash each | **1 hash each** |
| MiniAmiq d/t | 1 hash each | 1 hash each | **1 hash each** |
| SeqDriver d | 1 | 1 | **1** |
| SeqDriver t | 1 | 2 | **1** |
| SimpleUVM d | 1 | 2 | 2 (the symbol-tail coin below; pristine shows it too: 1 of 6 direct draws) |
| SimpleUVM t | 1 | 1 | **1** |
| Scoreboard d | 1 | 2 | 2 (the known svunit listing coin) |
| BuildUVMPkg d | 1 | **3** | **1** |
| BuildUVMPkg t | 1 | 1 | **1** |

**The finding: the symbol-table tail is written in address order, and the unreserved draft disturbed the addresses.**
Every differing pair above reads identical in `uhdm-dump` and identical in an id-order listing of every object with its
parent and actual (drivers/tool/idlist.cpp: 0 lines); only the tail of the symbol table differs (drivers/tool/
symlist.cpp: 86 to 148 strings, all full names of references inside method-call arguments and formal defaults, e.g.
`uvm_pkg::uvm_phase::add::after_phase.is_before::before_phase`, `svaunit_pkg::uvm_mem::write::path::UVM_DEFAULT_PATH`).
Those strings are registered by **§ refFullNameThroughNamedExpr175 and its § methodArgNestedRefChain201 loop
(ExprEmit.cpp `refFullNameThroughNamedExpr175`, called from ParamEmit.cpp `UhdmExporter::drainPaNameCopySrc38`)**, which
iterate `Serializer::AllObjects()`, a `std::map` keyed by object ADDRESS, and set fresh `VpiFullName` strings in that
order. It is the pre-existing coin r11u221 named for MiniAmiq ("symbol-table ordering, 842 lines in the ordered dump
and 0 order-blind", item (5) of the brief): six concurrent pristine MiniAmiq draws gave 5 + 1 hashes, the odd one
differing in 86 tail strings of exactly this family and in nothing else
([evidence/det/miniamiq_pristine_symtail.txt](evidence/det/miniamiq_pristine_symtail.txt)). **Item (5) is decoded to
that call site, on the sister's ground**: collecting the objects and sorting them by UhdmId before the two loops (as
§ lawSCopyIdOrder186 did for LAW S) fixes it with no record moving; not written here (ExprEmit.cpp).

The draft `law` grew the formal registry by `push_back` during emission; the freed and re-allocated heap blocks moved
later UHDM objects' addresses and turned that latent order into a frequent coin: BuildUVMPkg default read 4 odd of 16
and 2 odd of 16 concurrent draws on `law`, 0 of 16 on pristine
([evidence/det/builduvmpkg_draws.txt](evidence/det/builduvmpkg_draws.txt)). *Verification note (tools/probe/v11u223repro, section 4):* the reserved registry still left MiniAmiq default and
SimpleUVM default byte coins (9 : 10 and 9 : 9 : 1 in 19 draws, against one hash on the base binary);
§ formalRegNoHeap223v moves the registry to static storage. **`law_d5` reserves the registry once**
(one mapping, never reallocated; src/R223.h): 16 of 16 draws one hash, and its symbol table equals pristine's string for
string (0 differing lines, where `law`'s majority draw differed in 200). The gate sweeps' verdicts are identical under
both binaries.

The laws themselves mint in a deterministic order: the formal registry is a vector in emission order (reserved), the
adjuster pass sorts the net-declaration assignments by UhdmId and only rewrites fields, the placeholder decline mints
nothing (its object and its vector live outside the serializer). The reservation covers 65536 recorded formals;
a design with more would grow the registry as the draft did (a determinism exposure of the pre-existing coin above,
never a record change).

## 10. Fence and process

* **The fence**: every driver that reads corpus sources or databases takes the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (drivers/env.sh, case.sh, census.sh with `--filter` built from
  them, predict.py, movers.sh and bvmirror.sh skipping the fenced row-mode directories unread (8 per sweep),
  awayall.py, uvmdist.sh, dscases.py, det.sh). The gate sweeps dispatched every row, as the gate mandates; their csv
  verdicts are the only fenced facts used. The shipped surelog csv has the fenced rows removed
  ([evidence/final/law_surelog_unfenced.csv](evidence/final/law_surelog_unfenced.csv)), and the shipped uhdm2rtlil and
  downstream csvs have the rows removed whose test name CONTAINS a fenced name as a substring (one uhdm2rtlil test, both
  modes, IDENTICAL / CMP_EQUAL in both sweeps), so the integration's substring check of the patch reads 0 for all four
  names; a grep of this directory for the four names, word or substring, reads 0. No binary, gdb run or script touched a fenced test's sources or databases outside the gate
  sweeps. The gdb run of section 3.1 was on a tools/probe case.
* **The root cause of the stray binary-named file of 2026-09-28** (the brief's note: "a stray empty file with a binary
  name appeared in the main tree's root ... its writer was never found"): **reproduced twice by this pass on its own
  scratch.** slang-uhdm and Surelog write their `.uhdm` databases with mode 0700 (executable), and a UHDM database's
  first bytes contain `>` (0x3E) followed by control bytes (`! 001 004 003 307 003 P 001 322 021 001 > 023 E ...`).
  A command such as `$UHDM_DUMP db.uhdm` or `$UHDM_CMP golden.uhdm ours.uhdm` run in a shell where the variable is
  unset executes the DATABASE as a shell script; bash reports `command not found` for each garbage line, and the `>`
  bytes redirect into a zero-length file whose name is the following bytes, in the current directory. This pass did
  exactly that twice (a fresh shell without drivers/env.sh sourced): once in the tools/probe/v11u219repro/cases/S/
  s01c_assoc_inner directory of the worktree (`E\003\217\023...`, 00:46) and once in its own law sweep's
  `surelog/` directory (after executing a cached golden, 01:36); both zero-length files were found by `git status` / a
  directory listing and deleted, nothing else was written (every other line was `command not found`). Guard for every
  operator and driver: never call a tool through an unset variable (`[ -x "$UHDM_CMP" ] || exit`), or source the pins
  first; this pass's drivers all source drivers/env.sh.
* **Process**: the pristine binary was frozen before any edit; the prediction was written after the last law and
  frozen (md5 above) before the law sweep; the two gate sweeps ran one at a time; builds ran `-j 1` whenever
  `free -g` showed less than 6 GB available (another pass was compiling), `-j 2` otherwise. Drafts d1-d3 were measured on the grid and the UVM rows only.

## 11. Residues, ranked

1. **`UVM_SEQ_ARB_TYPE`, the new head of MiniAmiq d/t and SeqDriver d/t** (decoded, not written; ground B,
   UhdmExporter's formal-writer model). `typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE;` is an alias of an alias;
   `uvm_sequencer_base::set_arbitration` is declared `extern` in the class (uvm_sequencer_base.svh 332) and defined out
   of body (1381). Golden's DEFINITION listing holds the out-of-body definition's formal at the PROTOTYPE's token
   332:40-56, ours at the definition's 1381:51-67; the elaborated listings agree at 332:40. The small case
   evidence/decode/E_externalias/e04 reproduces golden (definition listing `p::ALIAS_T` 6:30, the prototype) but is
   stage 1 at the base (our definition listing lists the chain typedef differently); e02 (the enum itself, not an
   alias) is STRICT_EQUAL with golden writing the out-of-body definition 7:24 there. So for an alias-of-alias the
   out-of-body definition of an extern method is no writer (compileFunction returns early on the populated prototype,
   § externProtoFormalsFromPrototype175's decode) while for a direct enum it is: the distinguisher is the chain, and
   § tfArgClassMethodOrder176's definition-listing writer ("the package's own items, out-of-body definitions
   included") needs that exception. The next pass on this ground should grid the four shapes (enum / alias x extern /
   in-body) in both listings before writing it.
2. **`this_type`, the new head of SimpleUVM d/t, Scoreboard d and BuildUVMPkg d/t** (decoded in part): the out-of-body
   definition `uvm_sequence_library::m_check(..., this_type lib)` (uvm_sequence_library.svh 532) binds, in golden,
   ANOTHER class's `this_type` typedef (uvm_algorithmic_comparator's, 74:11-37): compileDatastructureTypespec runs in
   the package component, where `this_type` is no data type, and falls through to the design-wide lookups; ours binds
   the class's own. The small case evidence/decode/T_oobthistype/t01 is stage 1 at the base (the module listing of the
   class typedefs). Ground B; which class wins needs Surelog's DataType map order (FileContent::getDataType over
   getAllFileContents).
3. **Package-qualified scalar formals** (F/f13 `p::UVM_FILE file`, `input p::UVM_FILE g`): golden binds the LISTING
   object `p::UVM_FILE` (no clone: a scoped name resolves to the typedef object) and MOVES it to the last qualified
   token (5:47-5:58, the whole scoped name under `input`), the relocation model of § tfArgQualOutsideWriter176, which
   admits enum and aggregate typedefs only. Not recorded by this pass (bytes unchanged). Ground B.
4. **pass 219's x03** (an enum alias read by a `$unit` class method formal): the enum relocation writer model declines a
   class outside any package or module (§ tfArgOutsideClassOrder216's `ok216`); a `$unit` class key in Surelog's class
   map is not decoded yet. The scalar half converts (F/f23).
5. **Golden's generic-handler `$size` value in the PARSE view** (v11u219 s04 w1, s08, own S/s03 s04 parse views): the
   parse view keeps the call; golden writes the folded constant there too. Transcribing UHDM ExprEval's `$size` branch
   (the dimension walker and the generic `size(object, full=false)`: element size times the last range) into
   ModuleEmit's rqSizePlan216 would convert them; the elaborated view now writes exactly what golden writes.
   v11u219 s04 elaborated's next head is `$size(ps, 1)` of a packed struct: golden keeps the call stamped with the
   module's typespec (ground A's call stamp).
6. **Sized and based range bounds** (decoded, evidence/decode/B_basedbound b01-b04, both views): golden keeps a based
   bound as written: `logic [4'h7:0]` -> `HEX:7`, size 4, decompile `4'h7`, span the whole literal 3:10-3:14; `8'd7` ->
   `DEC:7` size 8 type 1; `3'b111:3'b000` -> `BIN:111` / `BIN:000` size 3 (leading zeros kept); the plain `0` bound stays
   `UINT:0` size 64. Ours folds to `UINT:7` at the size token (stage 1 in all eight case-views). The syntax-built
   constant of TypeEmit emitSyntaxExpr's IntegerVectorExpression branch is exactly golden's shape; the range-bound
   builders of makeTypespec (several `mkBound` lambdas) would call it for a based literal bound. Not written: seven
   builder sites, and no measured corpus reach.
7. **Macro-argument formal columns** (F/f15, f29): the formal's typespec now follows our location model; the io_decl
   and the typespec columns inside a macro expansion differ from golden's expanded-text columns (golden f15 io_decl
   6:41, ours 6:29): UhdmExporter's preprocessor model (§ ppIdentEndInRebuiltText219's family).
8. **The fixed `[N]` unpacked bound** (every C case, own S/s01): golden keeps `N-1` as an operation on a leading-fixed
   dimension of an unsized-inner array, ours the folded `UINT:N-1`: ground A.
9. **Not attempted**: item (3)'s nested-class writers and the enumImportParentDrain180 ranking, UVM_MACRO_NUMFLAGS;
   item (4) (svaunit clone names, N0008; the r11u218 return-variable law is ParamEmit's, pair A's); item (5) MiniAmiq's
   symbol-table coin; item (6) (pass 212 and 216 residues, cfg_func_width_loop #464); item (7)'s downstream faces other
   than those above.

## 12. Files

* **cases/**: F (29 cases: the scalar typedef formal and its DPI refinement; f25 is two files with an `args` file,
  its package file naming the law too; f26 and f28 carry an included header), C (8: the element of an unsized-inner array), S (4: the elaborated `$size`
  crash and sizing). Every case's first line names its law.
* **evidence/decode/**: B_basedbound, E_externalias, T_oobthistype (decode cases of residues 1, 2 and 6; no law of this
  pass). Each source is `dut.sv.txt` with an `args` file naming it, so the law index does not attach them to this
  pass's laws; drivers/case.sh runs them as they are (`bash drivers/case.sh evidence/decode/E_externalias/e04 P <bin>`).
* **drivers/**: env.sh (pins, fence), case.sh, grid.sh, switches.sh, census.sh, predict.py, movers.sh, bvmirror.sh,
  awayall.py, away2.py, uvmdist.sh, det.sh, dscases.py, widebytes.sh (from r11u219, not run here), tool/idlist.cpp and
  tool/symlist.cpp (the id-order object lister and the symbol-table lister of section 9, built with the flags of
  tools/probe/r11u211map/drivers/cc.sh).
* **evidence/**: grid_law.tsv, switches_{F,C,S}.txt, census/ (the frozen prediction), final/ (gate summaries of the
  final and the first law sweep, csvs with the fenced rows removed, movers, byteverify), away_canonical{,_reversed}.txt,
  heads/ (first records, pristine and final), uvmdist_{pristine,law}.txt, ds_cases.txt, rc_elab_nodb.txt,
  det_{law,pris}.txt and det/ (the draws of section 9).
* tests/LAWS.md regenerated (`python3 scripts/law_index.py`).

